package com.example.nhom_bar.spatial

import android.app.Activity
import android.content.Intent
import com.google.ar.core.ArCoreApk
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.io.DataInputStream
import java.io.DataOutputStream
import java.util.UUID

/** Models stay in app-private storage, independently of Firebase and login state. */
object SpatialBridge {
    @JvmStatic fun handle(activity: Activity, call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "capabilities" -> result.success(mapOf(
                    "arcore" to ArCoreApk.getInstance().checkAvailability(activity).toString(),
                    "platform" to "android"))
                "models" -> result.success(ModelStore.list(activity))
                "openPhotoModel" -> Thread {
                    var file: File? = null
                    try {
                        val bytes = requireNotNull(call.argument<ByteArray>("mesh"))
                        require(bytes.size in 7208..8_388_608)
                        DataInputStream(java.io.ByteArrayInputStream(bytes)).use {
                            ModelStore.readMesh(it)
                            require(it.available() == 0)
                        }
                        val created = File.createTempFile("triposr-", ".mesh", activity.cacheDir)
                        file = created
                        created.writeBytes(bytes)
                        val name = created.name
                        activity.runOnUiThread {
                            try {
                                activity.startActivity(Intent(activity, SpatialActivity::class.java)
                                    .putExtra("mode", "view").putExtra("photoMesh", name))
                                result.success(null)
                            } catch (error: Exception) {
                                file?.delete()
                                result.error("PHOTO_MODEL", "Chưa mở được mô hình.", null)
                            }
                        }
                    } catch (error: Exception) {
                        file?.delete()
                        activity.runOnUiThread { result.error("PHOTO_MODEL", "Mô hình không hợp lệ.", null) }
                    }
                }.start()
                "serverSettings" -> result.success(ScanServer.settings(activity))
                "saveServerSettings" -> Thread {
                    try {
                        ScanServer.pair(activity,call.argument<String>("address")?:"",call.argument<String>("code")?:"")
                        activity.runOnUiThread {result.success(null)}
                    }catch(e:Exception){
                        android.util.Log.w("MeoScanConnection","Pairing failed",e)
                        activity.runOnUiThread {result.error("SPATIAL_PAIRING","Chưa ghép nối được máy xử lý.",null)}
                    }
                }.start()
                "checkServerConnection" -> Thread {
                    try {
                        val (server,health)=ScanServer.ready(activity)
                        activity.runOnUiThread {result.success(mapOf("waiting" to health.optInt("waiting"),
                            "processing" to health.optInt("processing"),"ready" to true,"transport" to server.transport))}
                    }catch(e:Exception){
                        android.util.Log.w("MeoScanConnection","Connection check failed",e)
                        activity.runOnUiThread {result.error("SPATIAL_NETWORK","Chưa tìm thấy máy xử lý 3D",null)}
                    }
                }.start()
                "deleteModels" -> Thread {
                    try {
                        val ids=call.argument<List<String>>("ids")?:emptyList()
                        val deleted=ModelStore.delete(activity,ids)
                        activity.runOnUiThread {result.success(deleted)}
                    }catch(e:Exception){activity.runOnUiThread {result.error("SPATIAL_DELETE",e.message,null)}}
                }.start()
                "importPcModels" -> Thread {
                    try {
                        val count=PhotoCapture.importCompleted(activity)
                        activity.runOnUiThread {result.success(count)}
                    }catch(e:Exception){activity.runOnUiThread {result.error("SPATIAL_PC",e.message,null)}}
                }.start()
                "open" -> {
                    val mode = call.argument<String>("mode") ?: "scan"
                    require(mode in listOf("scan", "view", "ar", "vr"))
                    val id = call.argument<String>("id")
                    if (mode != "scan") require(id != null && ModelStore.validId(id) && ModelStore.exists(activity,id)) {"Mô hình đã bị xóa hoặc không còn đầy đủ."}
                    activity.startActivity(Intent(activity, SpatialActivity::class.java)
                        .putExtra("mode", mode).putExtra("id", id))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) { result.error("SPATIAL", e.message, null) }
    }
}

data class ScanMesh(val vertices: FloatArray, val colors: FloatArray, val uv:FloatArray?=null, val texture:ByteArray?=null) {
    val triangles get() = vertices.size / 9
}

object ModelStore {
    private val active=java.util.WeakHashMap<Activity,String>()
    @Synchronized fun use(a:Activity,id:String) {require(exists(a,id));active[a]=id}
    @Synchronized fun release(a:Activity) {active.remove(a)}
    fun exists(a:Activity,id:String)=validId(id) && File(root(a),"$id.json").isFile && File(root(a),"$id.mesh").isFile
    @Synchronized fun deletedJobs(a:Activity):Set<String> {
        val f=File(root(a),"deleted-pc-jobs.json")
        return if(!f.exists())emptySet() else org.json.JSONArray(f.readText()).let {j->(0 until j.length()).map {j.getString(it)}.toSet()}
    }
    @Synchronized fun delete(a:Activity,ids:List<String>):Int {
        require(ids.isNotEmpty() && ids.size<=500 && ids.all {validId(it)})
        val selected=ids.toSet()
        check(active.any { !it.key.isFinishing && it.value in selected }.not()) {"Có mô hình đang mở trong 3D/AR/VR. Đóng mô hình rồi xóa lại."}
        val directory=root(a).canonicalFile
        // Validate every selected file before deleting anything. A bad path in
        // a later model must not turn a batch request into an unnoticed partial deletion.
        val files=selected.associateWith {id->
            directory.listFiles()?.filter {it.name.startsWith("$id.")}?:emptyList()
        }
        for(file in files.values.flatten()) {
            check(file.canonicalFile.parentFile==directory && file.isFile) {"Tệp mô hình không hợp lệ."}
        }
        val jobs=deletedJobs(a).toMutableSet()
        for(id in selected) {
            val metadata=File(directory,"$id.json")
            if(metadata.isFile)JSONObject(metadata.readText()).optString("pcJob").takeIf {it.isNotBlank()}?.let {jobs.add(it)}
        }
        // Avoid silently re-importing a deleted model from an old completed PC job.
        val tombstone=File(directory,"deleted-pc-jobs.json.partial")
        tombstone.writeText(org.json.JSONArray(jobs.toList()).toString())
        check(tombstone.renameTo(File(directory,"deleted-pc-jobs.json")))
        var count=0
        for(id in selected) {
            val owned=files.getValue(id)
            for(file in owned) {
                check(file.canonicalFile.parentFile==directory && file.isFile) {"Tệp mô hình không hợp lệ."}
                check(file.delete()) {"Không xóa được ${file.name}; hãy thử lại."}
            }
            if(owned.isNotEmpty())count++
        }
        return count
    }
    fun readMesh(input:DataInputStream):ScanMesh {
        val magic=input.readInt();require(magic==0x53434e31 || magic==0x53434e32)
        val n=input.readInt();require(n in 900..3_000_000 && n%9==0)
        val vertices=FloatArray(n){input.readFloat()};val colors=FloatArray(n){input.readFloat()}
        require(vertices.all {it.isFinite()} && colors.all {it.isFinite() && it in 0f..255f})
        if(magic==0x53434e31)return ScanMesh(vertices,colors)
        val uv=FloatArray(n/3*2){input.readFloat()}
        require(uv.all {it.isFinite() && it in 0f..1f})
        val size=input.readInt();require(size in 1..32_000_000)
        val texture=ByteArray(size);input.readFully(texture)
        val options=android.graphics.BitmapFactory.Options().apply {inJustDecodeBounds=true}
        android.graphics.BitmapFactory.decodeByteArray(texture,0,size,options)
        require(options.outWidth in 1..4096 && options.outHeight in 1..4096) {"Texture vượt giới hạn bộ nhớ."}
        return ScanMesh(vertices,colors,uv,texture)
    }
    private fun writeMesh(out:DataOutputStream,mesh:ScanMesh) {
        val textured=mesh.uv!=null && mesh.texture!=null
        out.writeInt(if(textured)0x53434e32 else 0x53434e31);out.writeInt(mesh.vertices.size)
        mesh.vertices.forEach {out.writeFloat(it)};mesh.colors.forEach {out.writeFloat(it)}
        if(textured){mesh.uv!!.forEach {out.writeFloat(it)};out.writeInt(mesh.texture!!.size);out.write(mesh.texture)}
    }
    fun validId(id: String) = id.matches(Regex("[a-f0-9-]{36}"))
    private fun root(a: Activity) = File(a.filesDir, "spatial_models").apply { mkdirs() }
    @Synchronized fun list(a: Activity): List<Map<String, Any>> = root(a).listFiles()
        ?.filter { it.extension == "json" && validId(it.nameWithoutExtension) }
        ?.mapNotNull { f -> try {
            val j = JSONObject(f.readText())
            if (!File(root(a), "${f.nameWithoutExtension}.mesh").isFile) null else mapOf(
                "id" to f.nameWithoutExtension, "name" to j.getString("name"),
                "created" to j.getLong("created"), "triangles" to j.getInt("triangles"),
                "coverage" to j.getInt("coverage"), "frames" to j.getInt("frames"),
                "source" to j.optString("source","depth"),
                "pcJob" to j.optString("pcJob",""),
                "textured" to j.optBoolean("textured",false),
                "scaleEstimated" to j.optBoolean("scaleEstimated",j.optString("source")=="photogrammetry"),
                "quality" to j.optString("quality",""),
                "qualityVersion" to j.optInt("qualityVersion",0),
                "scanComplete" to j.optBoolean("scanComplete", false),
                "arComplete" to j.optBoolean("arComplete", false),
                "vrComplete" to j.optBoolean("vrComplete", false))
        } catch (_: Exception) { null } }?.sortedByDescending { it["created"] as Long } ?: emptyList()

    @Synchronized fun save(a: Activity, mesh: ScanMesh, frames: Int, coverage: Int, complete: Boolean, source:String="depth", pcJob:String="", scaleEstimated:Boolean=false, quality:String="", qualityVersion:Int=4): String {
        require(mesh.triangles >= 100) { "Chưa đủ bề mặt thật để lưu mô hình." }
        require(mesh.vertices.size == mesh.colors.size && mesh.vertices.all { it.isFinite() })
        val id = UUID.randomUUID().toString()
        val dir = root(a)
        val temp = File(dir, "$id.partial")
        DataOutputStream(temp.outputStream().buffered()).use { out ->
            writeMesh(out,mesh)
        }
        check(temp.renameTo(File(dir, "$id.mesh")))
        val date = java.text.SimpleDateFormat("dd/MM HH:mm", java.util.Locale.getDefault()).format(java.util.Date())
        val j = JSONObject().put("name", "Vật thể $date").put("created", System.currentTimeMillis())
            .put("triangles", mesh.triangles).put("frames", frames).put("coverage", coverage)
            .put("scanComplete", complete).put("arComplete", false).put("vrComplete", false).put("source",source)
            .put("pcJob",pcJob).put("textured",mesh.texture!=null).put("scaleEstimated",scaleEstimated).put("quality",quality).put("qualityVersion",qualityVersion)
        // Portable, colored PLY alongside the binary used by both games.
        val plyTemp = File(dir, "$id.ply.partial")
        plyTemp.bufferedWriter().use { out ->
            val count = mesh.vertices.size / 3
            out.append("ply\nformat ascii 1.0\nelement vertex $count\nproperty float x\nproperty float y\nproperty float z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\nelement face ${mesh.triangles}\nproperty list uchar int vertex_indices\nend_header\n")
            for (i in 0 until count) {
                val p = i * 3
                out.append("${mesh.vertices[p]} ${mesh.vertices[p+1]} ${mesh.vertices[p+2]} ${mesh.colors[p].toInt()} ${mesh.colors[p+1].toInt()} ${mesh.colors[p+2].toInt()}\n")
            }
            for (i in 0 until mesh.triangles) out.append("3 ${i*3} ${i*3+1} ${i*3+2}\n")
        }
        check(plyTemp.renameTo(File(dir, "$id.ply")))
        if(mesh.uv!=null && mesh.texture!=null) {
            val archive=File(dir,"$id.obj.zip.partial")
            java.util.zip.ZipOutputStream(archive.outputStream().buffered()).use {zip->
                fun entry(name:String,text:String){zip.putNextEntry(java.util.zip.ZipEntry(name));zip.write(text.toByteArray(Charsets.UTF_8));zip.closeEntry()}
                val obj=StringBuilder("mtllib model.mtl\nusemtl scan\n")
                for(i in mesh.vertices.indices step 3)obj.append("v ${mesh.vertices[i]} ${mesh.vertices[i+1]} ${mesh.vertices[i+2]}\n")
                for(i in mesh.uv.indices step 2)obj.append("vt ${mesh.uv[i]} ${mesh.uv[i+1]}\n")
                for(i in 0 until mesh.triangles)obj.append("f ${i*3+1}/${i*3+1} ${i*3+2}/${i*3+2} ${i*3+3}/${i*3+3}\n")
                entry("model.obj",obj.toString());entry("model.mtl","newmtl scan\nKd 1 1 1\nmap_Kd texture.png\n")
                zip.putNextEntry(java.util.zip.ZipEntry("texture.png"));zip.write(mesh.texture);zip.closeEntry()
            }
            check(archive.renameTo(File(dir,"$id.obj.zip")))
        }
        // Publish the library entry only after both model files have finished writing.
        val metadata = File(dir, "$id.json.partial").apply { writeText(j.toString()) }
        check(metadata.renameTo(File(dir, "$id.json")))
        return id
    }
    @Synchronized fun load(a: Activity, id: String): ScanMesh {
        require(validId(id))
        return DataInputStream(File(root(a), "$id.mesh").inputStream().buffered()).use { input ->
            readMesh(input)
        }
    }
    @Synchronized fun complete(a: Activity, id: String, mode: String) {
        require(validId(id) && mode in listOf("ar", "vr"))
        val f = File(root(a), "$id.json")
        check(f.isFile) {"Mô hình không còn tồn tại."}
        val json = JSONObject(f.readText()).put("${mode}Complete", true)
        val tmp = File(root(a), "$id.json.partial").apply { writeText(json.toString()) }
        check(tmp.renameTo(f))
    }
}
