package com.example.nhom_bar.spatial

import android.media.Image
import com.google.ar.core.Frame
import com.google.ar.core.Pose
import com.google.ar.core.Coordinates2d
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.*

/** Confidence-filtered, anchor-local projective TSDF. Fusion never blocks the camera thread. */
class DepthVolume(val radius: Float, val origin: FloatArray, private val n: Int = 96) {
    private val step = radius * 2 / (n - 1)
    private val truncation = max(step * 3, .008f)
    private val field = FloatArray(n*n*n) { 1f }
    private val weights = FloatArray(field.size)
    private val colorWeights = FloatArray(field.size)
    private val red = FloatArray(field.size) { 160f }
    private val green = FloatArray(field.size) { 160f }
    private val blue = FloatArray(field.size) { 160f }
    private val worker = Executors.newSingleThreadExecutor()
    private val working = AtomicBoolean(false)
    private val gate = ScanFrameGate()
    private val updateIds=IntArray(field.size)
    private val updateValues=FloatArray(field.size)
    private val updatePixels=IntArray(field.size)
    private val updateColors=IntArray(field.size)
    private var lastDepthTimestamp = -1L
    val sectors = IntArray(24)
    @Volatile var frames = 0; private set
    @Volatile var surfaceUpdates = 0; private set
    @Volatile var currentAngle = 0; private set
    @Volatile var highAngle = false; private set
    @Volatile var rejected = 0; private set
    @Volatile var hint = "Chờ Raw Depth có độ tin cậy cao."; private set
    @Volatile var distance = 0f; private set
    val voxelMillimeters get() = step*1000
    val coverage get() = sectors.count { it >= 2 } * 100 / sectors.size
    val missionReady get() = frames >= 40 && sectors.take(12).count { it >= 2 } >= 9 &&
        sectors.drop(12).count { it >= 2 } >= 9 && coverage >= 75

    private data class Plane(val bytes: ByteArray, val row: Int, val pixel: Int)
    private fun copy(image: Image, i: Int): Plane {
        val p=image.planes[i]; val b=p.buffer.duplicate(); b.rewind()
        return Plane(ByteArray(b.remaining()).also { b.get(it) },p.rowStride,p.pixelStride)
    }
    private data class Observation(val width:Int,val height:Int,val depth:Plane,val confidence:Plane,
        val matrix:FloatArray,val intr:FloatArray,val affine:FloatArray,
        val color:List<Plane>?,val colorWidth:Int,val colorHeight:Int,val camera:Pose)

    fun integrate(frame: Frame, depth: Image, confidence: Image?, color: Image?, anchor: Pose): Boolean {
        // Smoothed/interpolated depth must not masquerade as independent raw measurements.
        if(confidence==null || depth.timestamp!=confidence.timestamp || depth.width!=confidence.width ||
            depth.height!=confidence.height || depth.timestamp==lastDepthTimestamp || working.get()) return false
        val camera=anchor.inverse().compose(frame.camera.pose)
        distance=sqrt(camera.tx().pow(2)+(camera.ty()-radius).pow(2)+camera.tz().pow(2))
        if(distance !in .25f..1.2f) {
            hint="Khoảng cách ${(distance*100).toInt()} cm: giữ camera cách vật khoảng 25–100 cm."
            rejected++;return false
        }
        if(!gate.accept(frame,camera)) {hint=gate.message;rejected++;return false}
        val intrinsics=frame.camera.imageIntrinsics;val dims=intrinsics.imageDimensions
        val f=intrinsics.focalLength;val c=intrinsics.principalPoint
        val reference=SpatialRenderer.buffer(floatArrayOf(0f,0f,dims[0].toFloat(),0f,0f,dims[1].toFloat()))
        val mapped=SpatialRenderer.buffer(FloatArray(6))
        // ARCore CPU image and depth may have different crops/aspect ratios.
        frame.transformCoordinates2d(Coordinates2d.IMAGE_PIXELS,reference,Coordinates2d.TEXTURE_NORMALIZED,mapped)
        val matrix=FloatArray(16);frame.camera.pose.inverse().compose(anchor).toMatrix(matrix,0)
        val affine=floatArrayOf(mapped[0],mapped[1],(mapped[2]-mapped[0])/dims[0],
            (mapped[4]-mapped[0])/dims[1],(mapped[3]-mapped[1])/dims[0],(mapped[5]-mapped[1])/dims[1])
        val alignedColor=color?.takeIf {abs(it.timestamp-frame.timestamp)<40_000_000L}
        val observation=Observation(depth.width,depth.height,copy(depth,0),copy(confidence,0),matrix,
            floatArrayOf(f[0],f[1],c[0],c[1],dims[0].toFloat(),dims[1].toFloat()),affine,
            alignedColor?.let { listOf(copy(it,0),copy(it,1),copy(it,2)) },
            alignedColor?.width?:0,alignedColor?.height?:0,camera)
        lastDepthTimestamp=depth.timestamp
        if(!working.compareAndSet(false,true))return false
        worker.execute {try {fuse(observation)} catch(e:Exception) {
            rejected++;hint="Không hợp nhất được khung: ${e.message}"
        } finally {working.set(false)}}
        return true
    }

    private fun fuse(o:Observation) {
        val count=o.width*o.height
        val measured=FloatArray(count);val certainty=FloatArray(count)
        fun raw(x:Int,y:Int):Float {
            val i=y*o.depth.row+x*o.depth.pixel
            if(i+1>=o.depth.bytes.size)return 0f
            return ((o.depth.bytes[i].toInt() and 255) or ((o.depth.bytes[i+1].toInt() and 255) shl 8))*.001f
        }
        val neighborhood=FloatArray(9)
        for(y in 1 until o.height-1)for(x in 1 until o.width-1) {
            val ci=y*o.confidence.row+x*o.confidence.pixel
            if(ci>=o.confidence.bytes.size)continue
            val confidence=o.confidence.bytes[ci].toInt() and 255
            if(confidence<180)continue
            val d=raw(x,y);if(d !in .20f..1.5f)continue
            var used=0;var edge=false
            val tolerance=max(.012f,.02f*d*d)
            for(dy in -1..1)for(dx in -1..1) {
                val v=raw(x+dx,y+dy)
                if(v>0) {
                    if(abs(v-d)>tolerance)edge=true
                    else neighborhood[used++]=v
                }
            }
            if(edge || used<3)continue
            neighborhood.sort(0,used)
            measured[y*o.width+x]=neighborhood[used/2]
            certainty[y*o.width+x]=(confidence/255f).pow(2)/(1+d*d)
        }
        val ids=updateIds;val values=updateValues;val pixels=updatePixels;val colors=updateColors
        val seenPixels=BooleanArray(count)
        var used=0;var samples=0;var compared=0;var inconsistent=0
        val m=o.matrix;val k=o.intr;val a=o.affine
        for(z in 0 until n)for(y in 0 until n)for(x in 0 until n) {
            val lx=x*step-radius;val ly=y*step;val lz=z*step-radius
            if(ly<step*1.5f || lx*lx+lz*lz>radius*radius)continue
            val px=m[0]*lx+m[4]*ly+m[8]*lz+m[12]
            val py=m[1]*lx+m[5]*ly+m[9]*lz+m[13]
            val pz=-(m[2]*lx+m[6]*ly+m[10]*lz+m[14])
            if(pz !in .20f..1.5f)continue
            val imageX=k[0]*px/pz+k[2];val imageY=k[3]-k[1]*py/pz
            val u=((a[0]+a[2]*imageX+a[3]*imageY)*o.width).toInt()
            val v=((a[1]+a[4]*imageX+a[5]*imageY)*o.height).toInt()
            if(u !in 0 until o.width || v !in 0 until o.height)continue
            val pixel=v*o.width+u;val d=measured[pixel]
            if(d==0f)continue
            val sdf=d-pz
            if(abs(sdf)>truncation)continue
            val i=x+n*(y+n*z);val normalized=sdf/truncation
            if(weights[i]>=2f && abs(field[i])<.45f) {
                compared++;if(abs(normalized-field[i])>.75f)inconsistent++
            }
            ids[used]=i;values[used]=normalized;pixels[used]=pixel;colors[used]=-1
            if(abs(sdf)<step && !seenPixels[pixel]) {seenPixels[pixel]=true;samples++}
            if(abs(sdf)<step && o.color!=null && imageX>=0 && imageY>=0 && imageX<k[4] && imageY<k[5]) {
                colors[used]=rgb(o,(imageX*o.colorWidth/k[4]).toInt(),(imageY*o.colorHeight/k[5]).toInt())
            }
            used++
        }
        // Transactional rejection: a bad frame must not partly corrupt the TSDF.
        if(samples<60 || (compared>100 && inconsistent>compared*.30f)) {
            rejected++;hint=if(samples<60) "Depth quá ít: đến gần hơn, chọn vùng nhỏ hoặc dùng Ảnh → PC."
                else "Góc mới không khớp bề mặt cũ: giữ vật đứng yên, quay lại góc trước."
            return
        }
        for(j in 0 until used) {
            val i=ids[j];val w=certainty[pixels[j]];val old=weights[i].coerceAtMost(24f)
            field[i]=(field[i]*old+values[j]*w)/(old+w);weights[i]=old+w
            val rgb=colors[j]
            if(rgb>=0) {
                val cw=colorWeights[i].coerceAtMost(12f)
                red[i]=(red[i]*cw+((rgb shr 16) and 255)*w)/(cw+w)
                green[i]=(green[i]*cw+((rgb shr 8) and 255)*w)/(cw+w)
                blue[i]=(blue[i]*cw+(rgb and 255)*w)/(cw+w)
                colorWeights[i]=cw+w
            }
        }
        frames++;surfaceUpdates+=samples
        val p=o.camera;val horizontal=sqrt(p.tx()*p.tx()+p.tz()*p.tz())
        val azimuth=((atan2(p.tz(),p.tx())+PI)/(2*PI)*12).toInt().coerceIn(0,11)
        val band=if(atan2(p.ty()-radius,horizontal)>.40f)1 else 0
        currentAngle=azimuth*30;highAngle=band==1;sectors[band*12+azimuth]++
        hint="Khoảng cách ${(distance*100).toInt()} cm · voxel ${"%.1f".format(voxelMillimeters)} mm. Đi chậm quanh vật ở hai độ cao."
    }

    private fun rgb(o:Observation,x:Int,y:Int):Int {
        val planes=o.color?:return -1
        if(x !in 0 until o.colorWidth || y !in 0 until o.colorHeight)return -1
        fun read(p:Plane,x:Int,y:Int)=p.bytes.getOrNull(y*p.row+x*p.pixel)?.toInt()?.and(255)?:128
        val yy=read(planes[0],x,y)-16;val u=read(planes[1],x/2,y/2)-128;val v=read(planes[2],x/2,y/2)-128
        val r=(1.164f*yy+1.596f*v).toInt().coerceIn(0,255)
        val g=(1.164f*yy-.392f*u-.813f*v).toInt().coerceIn(0,255)
        val b=(1.164f*yy+2.017f*u).toInt().coerceIn(0,255)
        return (r shl 16) or (g shl 8) or b
    }

    fun mesh(): ScanMesh = worker.submit<ScanMesh> { extractMesh() }.get()
    fun close() {worker.shutdown()}
    fun trackingLost() {gate.reset();hint="Tracking gián đoạn; đợi camera ổn định lại."}

    /** Marching tetrahedra only across cells observed from at least two real depth frames. */
    private fun extractMesh(): ScanMesh {
        val vertices = ArrayList<Float>(); val colors = ArrayList<Float>()
        val corners = arrayOf(intArrayOf(0,0,0),intArrayOf(1,0,0),intArrayOf(1,1,0),intArrayOf(0,1,0),
            intArrayOf(0,0,1),intArrayOf(1,0,1),intArrayOf(1,1,1),intArrayOf(0,1,1))
        val tetrahedra = arrayOf(intArrayOf(0,5,1,6),intArrayOf(0,1,2,6),intArrayOf(0,2,3,6),
            intArrayOf(0,3,7,6),intArrayOf(0,7,4,6),intArrayOf(0,4,5,6))
        val edges = arrayOf(intArrayOf(0,1),intArrayOf(0,2),intArrayOf(0,3),intArrayOf(1,2),intArrayOf(1,3),intArrayOf(2,3))
        val ids = IntArray(8)
        for (z in 0 until n-1) for (y in 0 until n-1) for (x in 0 until n-1) {
            for (j in 0..7) { val c = corners[j]; ids[j] = x+c[0]+n*(y+c[1]+n*(z+c[2])) }
            if (ids.any { weights[it] < 2.4f } || ids.all { field[it] >= 0 } || ids.all { field[it] < 0 }) continue
            for (tet in tetrahedra) {
                val intersections = ArrayList<FloatArray>(4)
                val crossEdges = ArrayList<IntArray>(4)
                for (edge in edges) {
                    val a = tet[edge[0]]; val b = tet[edge[1]]
                    val ia = ids[a]; val ib = ids[b]; val fa = field[ia]; val fb = field[ib]
                    if ((fa < 0) == (fb < 0)) continue
                    val t = fa/(fa-fb)
                    crossEdges.add(intArrayOf(a,b))
                    val ca = corners[a]; val cb = corners[b]
                    intersections.add(floatArrayOf(
                        (x+ca[0]+(cb[0]-ca[0])*t)*step-radius,
                        (y+ca[1]+(cb[1]-ca[1])*t)*step,
                        (z+ca[2]+(cb[2]-ca[2])*t)*step-radius,
                        (red[ia]+(red[ib]-red[ia])*t).coerceIn(0f,255f),
                        (green[ia]+(green[ib]-green[ia])*t).coerceIn(0f,255f),
                        (blue[ia]+(blue[ib]-blue[ia])*t).coerceIn(0f,255f)))
                }
                if (intersections.size < 3) continue
                // Order a four-edge intersection around its centroid before triangulation.
                if (intersections.size == 4) {
                    // Nonadjacent section vertices lie on disjoint tetrahedron edges.
                    val opposite = (1..3).first { j -> crossEdges[j].none { it in crossEdges[0] } }
                    if (opposite != 2) { val p = intersections[2]; intersections[2] = intersections[opposite]; intersections[opposite] = p }
                }
                val indices = if (intersections.size == 3) intArrayOf(0,1,2) else intArrayOf(0,1,2,0,2,3)
                // Orient every triangle toward increasing TSDF (observed free space).
                val gx = field[ids[1]]+field[ids[2]]+field[ids[5]]+field[ids[6]]-field[ids[0]]-field[ids[3]]-field[ids[4]]-field[ids[7]]
                val gy = field[ids[2]]+field[ids[3]]+field[ids[6]]+field[ids[7]]-field[ids[0]]-field[ids[1]]-field[ids[4]]-field[ids[5]]
                val gz = field[ids[4]]+field[ids[5]]+field[ids[6]]+field[ids[7]]-field[ids[0]]-field[ids[1]]-field[ids[2]]-field[ids[3]]
                for (t in indices.indices step 3) {
                    val a=intersections[indices[t]]; val b=intersections[indices[t+1]]; val c=intersections[indices[t+2]]
                    val ax=b[0]-a[0]; val ay=b[1]-a[1]; val az=b[2]-a[2]
                    val bx=c[0]-a[0]; val by=c[1]-a[1]; val bz=c[2]-a[2]
                    val nx=ay*bz-az*by; val ny=az*bx-ax*bz; val nz=ax*by-ay*bx
                    if(nx*nx+ny*ny+nz*nz < step*step*step*step*1e-6f) continue
                    val triangle=if(nx*gx+ny*gy+nz*gz<0) intArrayOf(indices[t],indices[t+2],indices[t+1])
                        else intArrayOf(indices[t],indices[t+1],indices[t+2])
                    for (j in triangle) {
                    val p = intersections[j]
                    for (k in 0..2) vertices.add(p[k])
                    for (k in 3..5) colors.add(p[k])
                }
                }
                check(vertices.size <= 1_800_000) { "Lưới quá lớn; giảm kích thước vùng quét." }
            }
        }
        return ScanMesh(vertices.toFloatArray(), colors.toFloatArray())
    }
}
