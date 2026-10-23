package com.example.nhom_bar.spatial

import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import com.google.ar.core.Frame
import com.google.ar.core.exceptions.NotYetAvailableException
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.DataInputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/** Continuous real-camera keyframes. The USB-local server estimates geometry independently of depth. */
class PhotoCapture {
    private data class Photo(val bytes:ByteArray,val info:JSONObject)
    private val photos=ArrayList<Photo>()
    private var lastTimestamp=0L
    private val gate=ScanFrameGate()
    private val sectors=IntArray(24)
    val count get()=photos.size
    val coverage get()=sectors.count {it>0}*100/24
    var hint="Giữ vật thể đứng yên; đi vòng chậm, đợi tracking ổn định.";private set
    fun add(frame:Frame):Boolean {
        if(count>=120 || frame.timestamp-lastTimestamp<650_000_000L)return false
        if(!gate.accept(frame)){hint=gate.message;return false}
        try{
            frame.acquireCameraImage().use {image->
                if(kotlin.math.abs(image.timestamp-frame.timestamp)>40_000_000L){hint="Ảnh và pose chưa đồng bộ; đợi khung mới.";return false}
                val luma=image.planes[0]
                var sum=0.0;var squared=0.0;var samples=0;var clipped=0
                fun luminance(x:Int,y:Int)=luma.buffer.get(y*luma.rowStride+x*luma.pixelStride).toInt() and 255
                for(y in image.height/5 until image.height*4/5 step 3)
                    for(x in image.width/5 until image.width*4/5 step 3) {
                        val value=luminance(x,y)
                        val lap=luminance(x-1,y)+luminance(x+1,y)+luminance(x,y-1)+luminance(x,y+1)-4*value
                        sum+=lap;squared+=lap.toDouble()*lap;samples++
                        if(value<8 || value>247)clipped++
                    }
                val sharpness=squared/samples-(sum/samples)*(sum/samples)
                if(sharpness<18 || clipped>samples*.35) {
                    hint="Ảnh mờ, thiếu chi tiết hoặc cháy sáng: dừng tay, lấy nét và tăng ánh sáng tán xạ."
                    return false
                }
                val factor=if(image.width>2048)2 else 1
                val w=(image.width/factor)/2*2;val h=(image.height/factor)/2*2
                val nv21=ByteArray(w*h*3/2)
                val y=image.planes[0];val u=image.planes[1];val v=image.planes[2]
                for(row in 0 until h)for(col in 0 until w)
                    nv21[row*w+col]=y.buffer.get(row*factor*y.rowStride+col*factor*y.pixelStride)
                for(row in 0 until h/2)for(col in 0 until w/2){
                    val out=w*h+row*w+col*2
                    nv21[out]=v.buffer.get(row*factor*v.rowStride+col*factor*v.pixelStride)
                    nv21[out+1]=u.buffer.get(row*factor*u.rowStride+col*factor*u.pixelStride)
                }
                val bytes=ByteArrayOutputStream()
                check(YuvImage(nv21,ImageFormat.NV21,w,h,null).compressToJpeg(Rect(0,0,w,h),95,bytes))
                val intrinsics=frame.camera.imageIntrinsics
                val f=intrinsics.focalLength;val c=intrinsics.principalPoint;val size=intrinsics.imageDimensions
                val pose=FloatArray(16);frame.camera.pose.toMatrix(pose,0)
                val info=JSONObject().put("name","frame_%04d.jpg".format(count))
                    .put("width",w).put("height",h)
                    .put("intrinsics",JSONArray(listOf(f[0]*w/size[0],f[1]*h/size[1],c[0]*w/size[0],c[1]*h/size[1])))
                    .put("pose",JSONArray(pose.toList())).put("timestamp",image.timestamp)
                    .put("sharpness",sharpness).put("tracking","TRACKING")
                photos.add(Photo(bytes.toByteArray(),info));lastTimestamp=frame.timestamp
                val axis=frame.camera.pose.zAxis
                val angle=((kotlin.math.atan2(axis[2],axis[0])+Math.PI)/(2*Math.PI)*12).toInt().coerceIn(0,11)
                val high=kotlin.math.atan2(axis[1],kotlin.math.sqrt(axis[0]*axis[0]+axis[2]*axis[2]))>.4f
                sectors[(if(high)12 else 0)+angle]++
                hint="Độ phủ hướng camera $coverage% · ${"%.0f".format(sharpness)} điểm nét. Bổ sung cả góc thấp và góc cao."
                return true
            }
        }catch(_:NotYetAvailableException){return false}
    }
    fun reconstruct(progress:(Int,String)->Unit):PhotoResult {
        require(count>=30){"Cần ít nhất 30 ảnh rõ, có dịch chuyển thật. Tiếp tục di chuyển quanh vật thể."}
        check(serverReady()){"Máy tính chưa sẵn sàng. Mở tools/start-scan-server.ps1 và kết nối adb reverse tcp:8765 tcp:8765. Các ảnh đã thu vẫn đang được giữ trong phiên này."}
        val payload=ByteArrayOutputStream()
        ZipOutputStream(payload).use {zip->
            zip.putNextEntry(ZipEntry("manifest.json"))
            zip.write(JSONObject().put("frames",JSONArray(photos.map {it.info})).toString().toByteArray(Charsets.UTF_8));zip.closeEntry()
            for(photo in photos){zip.putNextEntry(ZipEntry("images/${photo.info.getString("name")}"));zip.write(photo.bytes);zip.closeEntry()}
        }
        progress(1,"Đang chuyển các ảnh đã thu qua USB tới máy tính này…")
        val upload=connection("/reconstruct").apply {
            requestMethod="POST";doOutput=true;setRequestProperty("Content-Type","application/zip")
            setFixedLengthStreamingMode(payload.size())
        }
        val job=try{
            upload.outputStream.use {payload.writeTo(it)}
            check(upload.responseCode==202){"Máy tính từ chối bộ ảnh (${upload.responseCode})."}
            JSONObject(upload.inputStream.bufferedReader().use {it.readText()}).getString("id")
        }finally{upload.disconnect()}
        require(job.matches(Regex("[a-f0-9-]{36}")))
        val deadline=System.currentTimeMillis()+45*60*1000L
        while(System.currentTimeMillis()<deadline){
            val request=connection("/jobs/$job")
            val state=try{JSONObject(request.inputStream.bufferedReader().use {it.readText()})}finally{request.disconnect()}
            val stage=state.optInt("progress")
            progress(stage,"${state.optString("message")}\n${count} ảnh camera · xử lý trên máy tính cục bộ")
            when(state.getString("state")){
                "error" -> error(state.getString("message"))
                "done" -> {
                    val download=connection("/jobs/$job/mesh")
                    val mesh=try{DataInputStream(download.inputStream.buffered()).use {ModelStore.readMesh(it)}}finally{download.disconnect()}
                    return PhotoResult(mesh,state.getInt("registered"),state.getInt("coverage"),
                        state.getBoolean("complete") && state.optInt("engineVersion")>=3,job,
                        state.optBoolean("scaleEstimated",true),state.optString("quality","Chưa kiểm định hình học."),
                        state.optInt("engineVersion"))
                }
            }
            Thread.sleep(1000)
        }
        error("Xử lý quá 45 phút. Bộ ảnh vẫn được giữ trên máy tính để tiếp tục.")
    }
    companion object {
        private fun json(path:String):JSONObject {
            val c=connection(path)
            return try{JSONObject(c.inputStream.bufferedReader().use {it.readText()})}finally{c.disconnect()}
        }
        fun importCompleted(activity:android.app.Activity):Int {
            check(serverReady()) {"Máy tính chưa sẵn sàng hoặc USB chưa kết nối."}
            val jobs=json("/jobs").getJSONArray("jobs")
            val existing=(ModelStore.list(activity).map {it["pcJob"]}+ModelStore.deletedJobs(activity)).toMutableSet()
            var count=0
            for(i in 0 until jobs.length()) {
                val job=jobs.getJSONObject(i);val id=job.getString("id")
                if(!ModelStore.validId(id) || id in existing || job.optString("state")!="done")continue
                val c=connection("/jobs/$id/mesh")
                val mesh=try{DataInputStream(c.inputStream.buffered()).use {ModelStore.readMesh(it)}}finally{c.disconnect()}
                ModelStore.save(activity,mesh,job.getInt("frames"),job.getInt("coverage"),
                    job.getBoolean("complete") && job.optInt("engineVersion")>=3,"photogrammetry",id,
                    job.optBoolean("scaleEstimated",true),job.optString("quality","Bản quét cũ chưa qua kiểm định mới."),job.optInt("engineVersion"))
                existing.add(id);count++
            }
            return count
        }
        private fun connection(path:String)=(URL("http://127.0.0.1:8765$path").openConnection() as HttpURLConnection).apply {
            connectTimeout=5000;readTimeout=120_000
        }
        fun serverReady():Boolean = try {
            val c=connection("/health")
            try{c.responseCode==200 && JSONObject(c.inputStream.bufferedReader().use {it.readText()}).optBoolean("ready")}finally{c.disconnect()}
        }catch(_:Exception){false}
    }
}

data class PhotoResult(val mesh:ScanMesh,val frames:Int,val coverage:Int,val complete:Boolean,val job:String,
    val scaleEstimated:Boolean,val quality:String,val qualityVersion:Int)
