package com.example.nhom_bar.spatial

import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.content.Context
import com.google.ar.core.Frame
import com.google.ar.core.Coordinates2d
import com.google.ar.core.Pose
import com.google.ar.core.exceptions.NotYetAvailableException
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.DataInputStream
import java.io.File
import java.io.IOException
import java.util.UUID
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/** Calibrated RGB/pose keyframes with optional independent Raw Depth observations. */
class PhotoCapture(private val context:Context) {
    private var server:ScanServer?=null
    private var requestId=UUID.randomUUID().toString()
    private var requestCount=-1
    private data class Photo(val bytes:ByteArray,val info:JSONObject,val depth:ByteArray?=null,val confidence:ByteArray?=null)
    private data class Raw(val bytes:ByteArray,val confidence:ByteArray,val info:JSONObject,val centerDistance:Float?)
    private val photos=ArrayList<Photo>()
    private val encoder=ScanWorkQueue<EncodedPhoto>()
    private data class EncodedPhoto(val photo:Photo?,val pose:Pose,val raw:Raw?,val center:FloatArray?)
    private var lastAttemptTimestamp=0L
    private val gate=ScanFrameGate()
    private val sectors=IntArray(24)
    private val sectorLimits=IntArray(24){6}
    private var lastDepthTimestamp=-1L
    private var byteCount=0L
    private var objectCenter:FloatArray?=null
    val count get()=photos.size
    val coverage get()=sectors.count {it>=2}*100/24
    val atCapacity get()=count>=MAX_FRAMES || byteCount>=120_000_000L
    val suggestedComplete get()=count>=72 && coverage>=75
    var hint="Giữ vật thể đứng yên; đi vòng chậm, đợi tracking ổn định.";private set
    fun add(frame:Frame):Boolean {
        val previousCount=count
        encoder.takeCompleted()?.let {accept(it)}
        schedule(frame)
        return count>previousCount
    }
    private fun schedule(frame:Frame) {
        if(atCapacity || !encoder.available() || frame.timestamp-lastAttemptTimestamp<650_000_000L)return
        if(!gate.accept(frame,requireTranslation=true)){hint=gate.message;return}
        if(sectors[sector(frame)]>=sectorLimits[sector(frame)]) {
            hint="Góc này đã đủ ảnh. Đi tiếp sang mặt bên/mặt sau hoặc nâng camera để bổ sung góc cao."
            return
        }
        objectCenter?.let {center->
            val pose=frame.camera.pose
            val distance=kotlin.math.sqrt((pose.tx()-center[0])*(pose.tx()-center[0])+
                (pose.ty()-center[1])*(pose.ty()-center[1])+(pose.tz()-center[2])*(pose.tz()-center[2]))
            if(distance !in .2f..1.5f){hint="Khoảng cách ${(distance*100).toInt()} cm: giữ trọn vật ở khoảng 25–120 cm.";return}
        }
        try{
            var timestamp=0L
            val copied=frame.acquireCameraImage().use {image->
                if(kotlin.math.abs(image.timestamp-frame.timestamp)>15_000_000L){hint="Ảnh và pose chưa đồng bộ; đợi khung mới.";return}
                timestamp=image.timestamp
                val planes=image.planes.map {ScanImagePlane.copy(it.buffer,it.rowStride,it.pixelStride)}
                ScanCameraImage(image.width,image.height,planes[0],planes[1],planes[2])
            } // Release camera resources BEFORE scheduling any expensive work.
            lastAttemptTimestamp=frame.timestamp
            val w=copied.outputWidth;val h=copied.outputHeight
            val intrinsics=frame.camera.imageIntrinsics
            val f=intrinsics.focalLength;val c=intrinsics.principalPoint;val size=intrinsics.imageDimensions
            val cameraPose=frame.camera.pose
            val pose=FloatArray(16);cameraPose.toMatrix(pose,0)
            val info=JSONObject().put("name","frame_%04d.jpg".format(count))
                .put("width",w).put("height",h)
                .put("intrinsics",JSONArray(listOf(f[0]*w/size[0],f[1]*h/size[1],c[0]*w/size[0],c[1]*h/size[1])))
                .put("pose",JSONArray(pose.toList())).put("timestamp",timestamp)
                .put("tracking","TRACKING")
            val raw=captureRaw(frame)
            var center:FloatArray?=null
            if(raw!=null) {
                info.put("depth",raw.info)
                if(objectCenter==null && raw.centerDistance!=null) {
                    val d=raw.centerDistance
                    val px=(size[0]*.5f-c[0])*d/f[0]
                    val py=(c[1]-size[1]*.5f)*d/f[1]
                    center=cameraPose.transformPoint(floatArrayOf(px,py,-d))
                }
            }
            encoder.submit {
                val started=System.nanoTime()
                val quality=copied.quality()
                if(!quality.acceptable)EncodedPhoto(null,cameraPose,null,null)
                else {
                    val bytes=ByteArrayOutputStream()
                    check(YuvImage(copied.nv21(),ImageFormat.NV21,w,h,null)
                        .compressToJpeg(Rect(0,0,w,h),95,bytes))
                    info.put("sharpness",quality.sharpness)
                    android.util.Log.d("MeoSpatial","IMAGE_ENCODE_MS=${(System.nanoTime()-started)/1_000_000}")
                    EncodedPhoto(Photo(bytes.toByteArray(),info,raw?.bytes,raw?.confidence),cameraPose,raw,center)
                }
            }
        }catch(_:NotYetAvailableException){return}
    }
    private fun accept(result:EncodedPhoto) {
        val photo=result.photo
        if(photo==null) {
            hint="Ảnh mờ, thiếu chi tiết hoặc cháy sáng: dừng tay, lấy nét và tăng ánh sáng tán xạ."
            return
        }
        result.raw?.let {lastDepthTimestamp=it.info.getLong("timestamp")}
        if(objectCenter==null)objectCenter=result.center
        photos.add(photo)
        byteCount+=photo.bytes.size+(photo.depth?.size?:0)+(photo.confidence?.size?:0)
        gate.commit(result.pose)
        sectors[sector(result.pose)]++
        hint="Giữ vật thể đứng yên; tiếp tục đi vòng chậm để chụp các mặt còn thiếu."
    }
    private fun sector(frame:Frame):Int {
        return sector(frame.camera.pose)
    }
    private fun sector(pose:Pose):Int {
        val axis=objectCenter?.let {center->floatArrayOf(pose.tx()-center[0],pose.ty()-center[1],pose.tz()-center[2])}?:pose.zAxis
        val angle=((kotlin.math.atan2(axis[2],axis[0])+Math.PI)/(2*Math.PI)*12).toInt().coerceIn(0,11)
        val high=kotlin.math.atan2(axis[1],kotlin.math.sqrt(axis[0]*axis[0]+axis[2]*axis[2]))>.4f
        return (if(high)12 else 0)+angle
    }
    private fun captureRaw(frame:Frame):Raw? {return try {
        frame.acquireRawDepthImage16Bits().use {depth->
            frame.acquireRawDepthConfidenceImage().use {confidence->
                // ARCore reprojects Raw Depth into this frame's camera pose.
                // Its measurement timestamp identifies independent evidence;
                // it need not equal the current RGB timestamp.
                if(depth.timestamp==lastDepthTimestamp || depth.timestamp!=confidence.timestamp ||
                    depth.width!=confidence.width || depth.height!=confidence.height)return null
                val w=depth.width;val h=depth.height
                if(w !in 1..1024 || h !in 1..1024)return null
                val dp=depth.planes[0];val cp=confidence.planes[0]
                val packed=ByteArray(w*h*2);val reliability=ByteArray(w*h)
                var good=0
                for(y in 0 until h)for(x in 0 until w) {
                    val from=y*dp.rowStride+x*dp.pixelStride;val to=(y*w+x)*2
                    packed[to]=dp.buffer.get(from);packed[to+1]=dp.buffer.get(from+1)
                    reliability[y*w+x]=cp.buffer.get(y*cp.rowStride+x*cp.pixelStride)
                    if((reliability[y*w+x].toInt() and 255)>=200 && (packed[to].toInt()!=0 || packed[to+1].toInt()!=0))good++
                }
                if(good<60)return null
                val input=SpatialRenderer.buffer(floatArrayOf(0f,0f,1f,0f,0f,1f))
                val output=SpatialRenderer.buffer(FloatArray(6))
                frame.transformCoordinates2d(Coordinates2d.IMAGE_NORMALIZED,input,Coordinates2d.TEXTURE_NORMALIZED,output)
                val affine=floatArrayOf(output[2]-output[0],output[4]-output[0],output[0],
                    output[3]-output[1],output[5]-output[1],output[1])
                val cx=((affine[0]*.5f+affine[1]*.5f+affine[2])*w).toInt()
                val cy=((affine[3]*.5f+affine[4]*.5f+affine[5])*h).toInt()
                val samples=ArrayList<Float>()
                for(y in cy-2..cy+2)for(x in cx-2..cx+2)if(x in 0 until w && y in 0 until h && (reliability[y*w+x].toInt() and 255)>=200) {
                    val i=(y*w+x)*2
                    val d=((packed[i].toInt() and 255) or ((packed[i+1].toInt() and 255) shl 8))*.001f
                    if(d in .15f..1.5f)samples.add(d)
                }
                samples.sort()
                Raw(packed,reliability,JSONObject().put("width",w).put("height",h)
                    .put("timestamp",depth.timestamp).put("encoding","uint16-le-mm")
                    .put("imageToDepth",JSONArray(affine.toList())),samples.takeIf {it.size>=3}?.let {it[it.size/2]})
            }
        }
    }catch(_:NotYetAvailableException){null}catch(_:IllegalStateException){null}}
    fun reconstruct(cancelled:()->Boolean={false},progress:(Int,String)->Unit):PhotoResult {
        // The render thread has stopped capture. Wait here, on the processing
        // thread, so the last accepted image cannot disappear from the upload.
        encoder.finishPending()?.let {accept(it)}
        require(count>=40){"Cần ít nhất 40 ảnh ở nhiều mặt. Tiếp tục đi quanh vật thể và bổ sung góc cao."}
        progress(0,"Đang kiểm tra kết nối USB / Wi-Fi với PC…")
        val network=server?:ScanServer.load(context).also {server=it}
        network.check()
        if(requestCount!=count){requestId=UUID.randomUUID().toString();requestCount=count}
        // Recover an accepted upload after a lost response, without submitting a duplicate job.
        var previous=network.json("/captures/$requestId").optString("id","").takeIf {ModelStore.validId(it)}
        // An explicit retry can re-submit a terminal engine error. Preserve the
        // original ID for queued/running/done jobs to avoid duplicate uploads.
        if(previous!=null && network.json("/jobs/$previous").optString("state")=="error") {
            requestId=UUID.randomUUID().toString()
            previous=null
        }
        val job=previous?:run {
        val payload=File.createTempFile("hybrid-upload-",".zip",context.cacheDir)
        try {
        ZipOutputStream(payload.outputStream().buffered()).use {zip->
            zip.putNextEntry(ZipEntry("manifest.json"))
            zip.write(JSONObject().put("version",5).put("frames",JSONArray(photos.map {it.info})).toString().toByteArray(Charsets.UTF_8));zip.closeEntry()
            for(photo in photos){
                val name=photo.info.getString("name")
                // JPEG is already compressed. Keep depth/manifest compression,
                // but avoid spending CPU compressing the same photograph twice.
                zip.setLevel(java.util.zip.Deflater.NO_COMPRESSION)
                zip.putNextEntry(ZipEntry("images/$name"));zip.write(photo.bytes);zip.closeEntry()
                zip.setLevel(java.util.zip.Deflater.DEFAULT_COMPRESSION)
                if(photo.depth!=null && photo.confidence!=null) {
                    val stem=name.substringBeforeLast('.')
                    zip.putNextEntry(ZipEntry("depth/$stem.u16"));zip.write(photo.depth);zip.closeEntry()
                    zip.putNextEntry(ZipEntry("depth/$stem.u8"));zip.write(photo.confidence);zip.closeEntry()
                }
            }
        }
        progress(1,"Đang gửi RGB/Depth qua ${network.transport} tới ${network.address}…")
        val upload=network.connection("/reconstruct").apply {
            requestMethod="POST";doOutput=true;setRequestProperty("Content-Type","application/zip")
            setRequestProperty("X-Capture-ID",requestId)
            setFixedLengthStreamingMode(payload.length())
        }
        try{
            upload.outputStream.use {out->payload.inputStream().use {it.copyTo(out)}}
            network.response(upload).getString("id")
        }catch(e:IOException) {
            // The PC may reject a full queue before consuming a large body.
            // Prefer its 429 message over the resulting socket write failure.
            try {network.response(upload).getString("id")}
            catch(error:ScanServer.ServerError){throw error}
            catch(_:Exception){throw IOException("Mất kết nối khi gửi. Bộ RGB/Depth vẫn còn; nhấn thử lại để tiếp tục đúng phiên.",e)}
        }finally{upload.disconnect()}
        }finally{payload.delete()}
        }
        require(job.matches(Regex("[a-f0-9-]{36}")))
        val deadline=System.currentTimeMillis()+90*60*1000L
        while(System.currentTimeMillis()<deadline){
            if(cancelled())throw java.util.concurrent.CancellationException("Đã đóng màn hình; phiên đã gửi vẫn được xử lý trên PC.")
            val state=try {network.json("/jobs/$job")}catch(e:IOException) {
                if(e is ScanServer.ServerError && e.status in listOf(401,403,404))throw e
                progress(0,"Mất kết nối ${network.transport} với PC. Đang thử kết nối lại; phiên $job vẫn được giữ trên máy tính.")
                Thread.sleep(3000)
                continue
            }
            val stage=state.optInt("progress")
            val status=if(state.optString("state")=="queued")"Đang chờ lượt ${state.optInt("queuePosition")}" else "Đang xử lý trên PC"
            progress(stage,"$status\n${state.optString("message")}\n$count ảnh camera · ${network.transport}")
            when(state.getString("state")){
                "error", "needs_more" -> {
                    hint=state.getString("message")
                    if(state.getString("state")=="needs_more") {
                        val missing=state.optJSONArray("missingAngles")
                        if(missing!=null && missing.length()>0) {
                            val names=ArrayList<String>()
                            for(i in 0 until missing.length()) {
                                val direction=missing.getJSONObject(i)
                                val angle=direction.getInt("angle")
                                val high=direction.getString("band")=="high"
                                val bin=angle/30+(if(high)12 else 0)
                                if(bin in 0..23)sectorLimits[bin]+=3
                                names.add("$angle° ${if(high)"cao" else "thấp"}")
                            }
                            hint+="\nGóc cần bổ sung: ${names.distinct().joinToString()}"
                        }else for(i in sectorLimits.indices)sectorLimits[i]++
                    }
                    error(hint)
                }
                "done" -> {
                    val download=network.connection("/jobs/$job/mesh")
                    val mesh=try {
                        if(download.responseCode!=200)network.response(download)
                        DataInputStream(download.inputStream.buffered()).use {ModelStore.readMesh(it)}
                    }catch(e:IOException) {
                        if(e is ScanServer.ServerError && e.status in listOf(401,403,404))throw e
                        progress(stage,"Mất kết nối khi tải mô hình. Đang thử tải lại từ PC…")
                        Thread.sleep(3000)
                        continue
                    }finally{download.disconnect()}
                    return PhotoResult(mesh,state.getInt("registered"),state.getInt("coverage"),
                        state.getBoolean("complete") && state.optInt("engineVersion")>=5,job,
                        state.optBoolean("scaleEstimated",true),state.optString("quality","Chưa kiểm định hình học."),
                        state.optInt("engineVersion"))
                }
            }
            Thread.sleep(1000)
        }
        error("Xử lý quá 90 phút. Bộ RGB/Depth vẫn được giữ trên máy tính để tiếp tục.")
    }
    fun close() {encoder.close()}
    companion object {
        const val MAX_FRAMES=180
        fun importCompleted(activity:android.app.Activity):Int {
            val network=ScanServer.load(activity)
            network.check()
            val jobs=network.json("/jobs").getJSONArray("jobs")
            val existing=(ModelStore.list(activity).map {it["pcJob"]}+ModelStore.deletedJobs(activity)).toMutableSet()
            var count=0
            for(i in 0 until jobs.length()) {
                val job=jobs.getJSONObject(i);val id=job.getString("id")
                if(!ModelStore.validId(id) || id in existing || job.optString("state")!="done")continue
                val c=network.connection("/jobs/$id/mesh")
                val mesh=try {
                    if(c.responseCode!=200)network.response(c)
                    DataInputStream(c.inputStream.buffered()).use {ModelStore.readMesh(it)}
                }finally{c.disconnect()}
                ModelStore.save(activity,mesh,job.getInt("frames"),job.getInt("coverage"),
                    job.getBoolean("complete") && job.optInt("engineVersion")>=5,"photogrammetry",id,
                    job.optBoolean("scaleEstimated",true),job.optString("quality","Bản quét cũ chưa qua kiểm định mới."),job.optInt("engineVersion"))
                existing.add(id);count++
            }
            return count
        }
    }
}

data class PhotoResult(val mesh:ScanMesh,val frames:Int,val coverage:Int,val complete:Boolean,val job:String,
    val scaleEstimated:Boolean,val quality:String,val qualityVersion:Int)
