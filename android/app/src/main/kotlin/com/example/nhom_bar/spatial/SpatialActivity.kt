package com.example.nhom_bar.spatial

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.pm.PackageManager
import android.graphics.Color
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.opengl.GLES20 as G
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.*
import com.google.ar.core.*
import com.google.ar.core.exceptions.NotYetAvailableException
import java.util.concurrent.atomic.AtomicBoolean
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.*

class SpatialActivity : Activity(), GLSurfaceView.Renderer, SensorEventListener {
    private lateinit var surface: GLSurfaceView
    private lateinit var status: TextView
    private lateinit var detail: TextView
    private lateinit var progress: ProgressBar
    private lateinit var primary: Button
    private lateinit var controls: LinearLayout
    private var aim: TextView? = null
    private var session: Session? = null
    private var mode = "scan"
    private var modelId: String? = null
    private var sourceMesh: ScanMesh? = null
    private var modelHeight = .3f
    private val renderer = SpatialRenderer()
    private var width = 1; private var height = 1
    private var boundSession: Session? = null
    private var boundTexture = -1
    private var geometryWidth = -1
    private var geometryHeight = -1
    private var geometryRotation = -1
    private var volume: DepthVolume? = null
    private var photoCapture: PhotoCapture? = null
    private var scanAnchor: Anchor? = null
    private var targetAnchor: Anchor? = null
    private var placementAnchor: Anchor? = null
    @Volatile private var busy = false
    @Volatile private var capturing = false
    @Volatile private var tap: Pair<Float,Float>? = null
    @Volatile private var radius = .18f
    @Volatile private var yaw = 0f
    @Volatile private var pitch = 18f
    @Volatile private var scale = 1f
    @Volatile private var cameraDistance = 1.2f
    @Volatile private var virtualX = 0f
    @Volatile private var virtualZ = 0f
    @Volatile private var stereo = false
    @Volatile private var headTracking = false
    @Volatile private var headYaw = 0f
    @Volatile private var headPitch = 0f
    private var headReference: Float? = null
    private var headPitchReference: Float? = null
    private var sensorManager: SensorManager? = null
    private var sensor: Sensor? = null
    private var lastFusion = 0L; private var lastUi = 0L
    private var round = 0; private var stableSince = 0L
    private var lastFrameMessage = ""
    private var permissionAsked = false
    private var installRequested = false
    private var cameraReported = false
    private var depthReported = false
    private val saving = AtomicBoolean(false)
    private val levels = floatArrayOf(45f,135f,270f)
    private val targetScales = floatArrayOf(.8f,1.2f,1f)
    private val completed = AtomicBoolean(false)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        mode = intent.getStringExtra("mode") ?: "scan"
        modelId = intent.getStringExtra("id")
        surface = GLSurfaceView(this).apply {
            setEGLContextClientVersion(2); setPreserveEGLContextOnPause(true)
            setRenderer(this@SpatialActivity)
        }
        val root = FrameLayout(this)
        root.addView(surface)
        if(mode=="scan"){
            aim=text("＋",32f).apply {setShadowLayer(4f,0f,0f,Color.BLACK);contentDescription="Tâm vùng chọn vật thể"}
            root.addView(aim,FrameLayout.LayoutParams(-2,-2,Gravity.CENTER))
        }
        val panel = LinearLayout(this).apply {
            orientation=LinearLayout.VERTICAL;setPadding(20,16,20,16)
            setBackgroundColor(0xd91a2234.toInt())
        }
        status=text("",20f);detail=text("",14f)
        progress=ProgressBar(this,null,android.R.attr.progressBarStyleHorizontal).apply { max=100 }
        panel.addView(status);panel.addView(detail);panel.addView(progress)
        root.addView(panel,FrameLayout.LayoutParams(-1,-2,Gravity.TOP).apply { topMargin=28 })
        val bottom=LinearLayout(this).apply {
            orientation=LinearLayout.VERTICAL;setPadding(12,8,12,16)
            setBackgroundColor(0xe51a2234.toInt())
        }
        controls=LinearLayout(this).apply {orientation=LinearLayout.HORIZONTAL}
        bottom.addView(controls)
        val actions=LinearLayout(this)
        actions.addView(button("← Sảnh") { finish() },LinearLayout.LayoutParams(0,-2,1f))
        primary=button(if(mode=="scan")"Bắt đầu quét" else "Hướng dẫn") {
            when(mode){
                "scan" -> if(capturing || (photoCapture?.count?:0)>=120)finishScan() else surface.queueEvent {
                    if(photoCapture!=null || volume!=null){capturing=true;runOnUiThread {primary.text="Dừng & tạo mô hình"}}
                    else {tap=Pair(width/2f,height/2f);Log.i("MeoSpatial","SELECT_CENTER_REQUESTED")}
                }
                else -> instructions()
            }
        }
        actions.addView(primary,LinearLayout.LayoutParams(0,-2,2f));bottom.addView(actions)
        root.addView(bottom,FrameLayout.LayoutParams(-1,-2,Gravity.BOTTOM))
        setContentView(root)
        configureControls()
        val detector=ScaleGestureDetector(this,object:ScaleGestureDetector.SimpleOnScaleGestureListener(){
            override fun onScale(d:ScaleGestureDetector):Boolean {
                if(mode=="view")cameraDistance=(cameraDistance/d.scaleFactor).coerceIn(.15f,8f)
                else scale=(scale*d.scaleFactor).coerceIn(.2f,3f)
                return true
            }
        })
        var oldX=0f;var oldY=0f;var downX=0f;var downY=0f;var moved=false
        surface.setOnTouchListener { _, event ->
            detector.onTouchEvent(event)
            when(event.actionMasked){
                MotionEvent.ACTION_DOWN -> {oldX=event.x;oldY=event.y;downX=event.x;downY=event.y;moved=false}
                MotionEvent.ACTION_POINTER_DOWN -> moved=true
                MotionEvent.ACTION_MOVE -> {
                    if(abs(event.x-downX)+abs(event.y-downY)>12)moved=true
                    if(!detector.isInProgress && event.pointerCount==1 && mode!="scan"){
                        yaw+=(event.x-oldX)*.45f
                        if(mode=="view")pitch=(pitch+(event.y-oldY)*.25f).coerceIn(-75f,75f)
                    };oldX=event.x;oldY=event.y
                }
                MotionEvent.ACTION_UP -> if(!moved && !detector.isInProgress){tap=Pair(event.x,event.y);Log.i("MeoSpatial","TAP x=${event.x} y=${event.y}")}
            };true
        }
        if(mode!="scan"){
            busy=true
            Thread {
                try {
                    ModelStore.use(this,requireNotNull(modelId))
                    val mesh=ModelStore.load(this,requireNotNull(modelId))
                    sourceMesh=mesh;modelHeight=mesh.vertices.filterIndexed {i,_->i%3==1}.maxOrNull()?.coerceAtLeast(.1f)?:.3f
                    surface.queueEvent {renderer.setMesh(mesh);busy=false}
                    runOnUiThread {configureControls()}
                }catch(e:Exception){runOnUiThread {showError("Không mở được mô hình",e)}}
            }.start()
        }
        if(mode=="vr"){
            sensorManager=getSystemService(SENSOR_SERVICE) as SensorManager
            sensor=sensorManager?.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR)
                ?:sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        }
        instructions()
    }

    private fun text(value:String,size:Float)=TextView(this).apply {text=value;textSize=size;setTextColor(Color.WHITE);setPadding(2,4,2,4)}
    private fun button(label:String,click:()->Unit)=Button(this).apply {text=label;textSize=12f;setOnClickListener {click()}}
    private fun addControl(label:String,click:()->Unit){controls.addView(button(label,click),LinearLayout.LayoutParams(0,-2,1f))}
    private fun configureControls(){
        controls.removeAllViews()
        when(mode){
            "scan" -> {
                addControl("Vùng nhỏ") {changeRadius(.10f)}
                addControl("Vừa") {changeRadius(.18f)}
                addControl("Lớn") {changeRadius(.30f)}
                addControl("Chọn lại") {surface.queueEvent {resetScan()}}
                addControl("Ảnh → PC") {startPhotoScan()}
            }
            "vr" -> {
                addControl("←") {virtualX=(virtualX-.04f).coerceIn(-1.5f,1.5f)}
                addControl("↑") {virtualZ=(virtualZ-.04f).coerceIn(-1.5f,1.5f)}
                addControl("↓") {virtualZ=(virtualZ+.04f).coerceIn(-1.5f,1.5f)}
                addControl("→") {virtualX=(virtualX+.04f).coerceIn(-1.5f,1.5f)}
                addControl("Kính") {
                    if(sensor==null)postStatus("Thiếu cảm biến","Dùng chế độ chạm; thiết bị không có cảm biến hướng phù hợp.")
                    else {stereo=!stereo;headTracking=stereo;headReference=null;headPitchReference=null;headYaw=yaw;headPitch=pitch;Toast.makeText(this,if(stereo)"Hai mắt: xoay đầu để nhìn; chạm mục tiêu để nhặt" else "Điều khiển bằng chạm",Toast.LENGTH_LONG).show()}
                }
            }
            "ar" -> {addControl("Xoay −15°") {yaw-=15};addControl("+15°") {yaw+=15};addControl("Nhỏ −") {scale=(scale-.05f).coerceAtLeast(.2f)};addControl("Lớn +") {scale=(scale+.05f).coerceAtMost(3f)}}
            "view" -> {
                addControl("Đặt lại góc nhìn") {yaw=0f;pitch=18f;cameraDistance=1.2f}
                addControl(if(sourceMesh?.texture!=null)"Xuất OBJ + texture" else "Xuất PLY") {exportModel()}
            }
        }
    }
    private fun changeRadius(value:Float){surface.queueEvent {if(!capturing){radius=value;resetScan()}}}
    private fun resetScan(){
        if(busy)return
        capturing=false;volume?.close();volume=null;photoCapture=null;scanAnchor?.detach();scanAnchor=null;lastFrameMessage=""
        runOnUiThread {primary.text="Bắt đầu quét"}
        postStatus("Chọn vùng quét · ${(radius*200).toInt()} cm", "Giữ vật thể đứng yên. Chạm trực tiếp giữa vật thể để bắt đầu quét bằng depth.")
    }
    private fun instructions(){
        val message=when(mode){
            "scan" -> "Giữ một vật thể đục, có chi tiết đứng yên trong vùng đủ sáng. Chọn cỡ vùng chứa vật thể, di chuyển camera nhẹ sang ngang để có depth, rồi chạm trực tiếp vào giữa vật thể để bắt đầu. Cần đo được mặt đỡ để loại mặt bàn khỏi bản quét. Vòng xanh là vùng giữ lại: chọn lại hoặc đổi cỡ nếu chưa bao hết vật thể. Đi vòng chậm ở hai độ cao. Mục tiêu: ít nhất 75% góc, 9 góc thấp + 9 góc cao và 40 khung Raw Depth độc lập, chất lượng cao. Kính, gương, vật quá nhỏ và mặt khuất có thể không tái tạo được. Chỉ dữ liệu từ camera được dùng."
            "ar" -> "Nhiệm vụ Sắp đặt: quét mặt bàn rồi chạm để đặt hình đích màu xanh. Chạm mặt bàn để di chuyển mô hình của bạn; vuốt ngang để xoay, chụm để đổi cỡ. Khớp vị trí trong 6 cm, góc trong 12° và cỡ trong 12%, giữ 2 giây. Hoàn thành 3 lượt để thắng."
            "vr" -> "Nhiệm vụ Thám hiểm: không gian 3D dùng mô hình bạn đã quét. Dùng mũi tên di chuyển quanh vật thể; vuốt để xoay và chụm để đổi cỡ. Tới gần 4 trạm sáng quanh mô hình, hướng tâm nhìn vào trạm rồi chạm để thu thập. Nếu có cảm biến hướng, nút Kính bật hai mắt và nhìn bằng chuyển động đầu. Đây là chế độ kính điện thoại, không phải tích hợp bộ điều khiển OpenXR."
            else -> "Mô hình được tái tạo từ ảnh camera hoặc khung depth của bạn. Vuốt để xoay, vuốt dọc đổi góc nhìn, chụm để phóng to. Mặt chưa quan sát có thể còn lỗ. Tệp mesh và PLY được lưu cục bộ trong dữ liệu ứng dụng."
        }
        AlertDialog.Builder(this).setTitle(when(mode){"scan"->"Game 3 · Thợ săn hình khối";"ar"->"Game 4 · Sắp đặt AR";"vr"->"Game 4 · Thám hiểm VR";else->"Mô hình của bạn"})
            .setMessage(message).setPositiveButton("Bắt đầu") {_,_->}.show()
    }

    override fun onResume(){
        super.onResume()
        if(mode=="scan"||mode=="ar"){
            if(checkSelfPermission(Manifest.permission.CAMERA)!=PackageManager.PERMISSION_GRANTED){
                if(!permissionAsked){permissionAsked=true;requestPermissions(arrayOf(Manifest.permission.CAMERA),41)}
                return
            }
            try{
                if(session==null){
                    val installed=ArCoreApk.getInstance().requestInstall(this,!installRequested)
                    if(installed==ArCoreApk.InstallStatus.INSTALL_REQUESTED){installRequested=true;return}
                    val s=Session(this)
                    if(mode=="scan" || mode=="ar"){
                        s.getSupportedCameraConfigs(CameraConfigFilter(s))
                            .filter {it.imageSize.width<=1920}
                            .maxByOrNull {it.imageSize.width*it.imageSize.height}
                            ?.let {s.cameraConfig=it}
                        Log.i("MeoSpatial","CAMERA_CPU_SIZE ${s.cameraConfig.imageSize}")
                    }
                    val config=Config(s).apply {
                        focusMode=Config.FocusMode.AUTO
                        planeFindingMode=Config.PlaneFindingMode.HORIZONTAL
                        updateMode=Config.UpdateMode.LATEST_CAMERA_IMAGE
                    }
                    if(mode=="scan" || mode=="ar"){
                        if(!s.isDepthModeSupported(Config.DepthMode.AUTOMATIC)){
                            if(mode=="scan")postStatus("Thiết bị không hỗ trợ Depth API","Chọn Ảnh → PC để thu ảnh liên tục và tái tạo trên máy tính kết nối USB.")
                        }else config.depthMode=Config.DepthMode.AUTOMATIC
                    }
                    s.configure(config);session=s
                    Log.i("MeoSpatial","ARCORE_CONFIGURED mode=$mode depth=${config.depthMode}")
                }
                session?.resume()
            }catch(e:Exception){showError("Không khởi động được ARCore",e);return}
        }
        surface.onResume()
        sensor?.let {sensorManager?.registerListener(this,it,SensorManager.SENSOR_DELAY_GAME)}
    }
    override fun onRequestPermissionsResult(code:Int,permissions:Array<out String>,results:IntArray){
        super.onRequestPermissionsResult(code,permissions,results)
        if(code==41){if(results.firstOrNull()==PackageManager.PERMISSION_GRANTED)onResume()
        else {postStatus("Chưa có quyền camera","Quay về và cấp quyền camera trong Cài đặt để quét/AR.");primary.isEnabled=false}}
    }
    override fun onPause(){
        capturing=false;stableSince=0
        if(mode=="scan" && volume!=null)primary.text="Tiếp tục quét"
        sensorManager?.unregisterListener(this)
        surface.onPause();session?.pause();super.onPause()
    }
    override fun onDestroy(){volume?.close();ModelStore.release(this);surface.queueEvent {scanAnchor?.detach();targetAnchor?.detach();placementAnchor?.detach()};session?.close();super.onDestroy()}
    override fun onSurfaceCreated(gl:GL10?,config:EGLConfig?){
        try{renderer.initialize();sourceMesh?.let {renderer.setMesh(it)}}catch(e:Exception){runOnUiThread{showError("Lỗi bộ dựng hình",e)}}
    }
    override fun onSurfaceChanged(gl:GL10?,w:Int,h:Int){width=w;height=h;G.glViewport(0,0,w,h)}

    override fun onDrawFrame(gl:GL10?){
        G.glViewport(0,0,width,height);G.glClearColor(.025f,.045f,.08f,1f);G.glClear(G.GL_COLOR_BUFFER_BIT or G.GL_DEPTH_BUFFER_BIT)
        if(mode=="vr"||mode=="view"){drawVirtual();return}
        val s=session?:return
        try{
            if(boundSession!==s || boundTexture!=renderer.cameraTexture){
                s.setCameraTextureName(renderer.cameraTexture);boundSession=s;boundTexture=renderer.cameraTexture
                geometryWidth=-1
            }
            @Suppress("DEPRECATION") val rotation=windowManager.defaultDisplay.rotation
            if(geometryWidth!=width || geometryHeight!=height || geometryRotation!=rotation){
                s.setDisplayGeometry(rotation,width,height)
                geometryWidth=width;geometryHeight=height;geometryRotation=rotation
            }
            val frame=s.update();if(frame.timestamp==0L)return
            renderer.camera(frame)
            if(!cameraReported){cameraReported=true;Log.i("MeoSpatial","CAMERA_FRAME mode=$mode timestamp=${frame.timestamp} tracking=${frame.camera.trackingState}")}
            if(mode=="scan" && photoCapture!=null){drawPhotoCapture(frame);return}
            if(frame.camera.trackingState!=TrackingState.TRACKING){
                volume?.trackingLost()
                stableSince=0;postThrottled("Đang tìm vị trí camera", "Di chuyển chậm, tăng ánh sáng. ${frame.camera.trackingFailureReason}");return
            }
            val projection=FloatArray(16);val view=FloatArray(16);val vp=FloatArray(16)
            frame.camera.getProjectionMatrix(projection,0,.05f,30f);frame.camera.getViewMatrix(view,0)
            Matrix.multiplyMM(vp,0,projection,0,view,0)
            tap?.let {touch ->tap=null;place(frame,touch.first,touch.second)}
            if(mode=="scan")drawScan(frame,vp) else drawAr(frame,vp)
        }catch(e:Exception){Log.e("MeoSpatial","frame failed",e);postThrottled("Không xử lý được khung hình",e.message?:e.javaClass.simpleName)}
    }

    private fun place(frame:Frame,x:Float,y:Float){
        if(busy || (mode=="scan"&&capturing))return
        if(mode=="scan"){
            selectFromDepth(frame,x,y)
            return
        }
        val hit=frame.hitTest(x,y).firstOrNull { h ->
            val p=h.trackable
            h.distance in .15f..4f && p.trackingState==TrackingState.TRACKING &&
                ((p is Plane && p.type==Plane.Type.HORIZONTAL_UPWARD_FACING && p.isPoseInPolygon(h.hitPose)) ||
                 p is Point || p is DepthPoint)
        }
        if(hit==null){postStatus("Điểm chọn chưa có vị trí 3D","Chạm vùng đường viền xanh đã nhận diện hoặc một góc có họa tiết. Di chuyển camera nhẹ sang hai bên để đo vị trí.");return}
        Log.i("MeoSpatial","AR_REAL_HIT type=${hit.trackable.javaClass.simpleName} distance=${hit.distance}")
        run {
            if(targetAnchor==null){targetAnchor=hit.createAnchor();virtualX=.35f;virtualZ=0f;yaw=0f;scale=1f}
            else {
                placementAnchor?.detach();placementAnchor=hit.createAnchor()
                val pose=requireNotNull(targetAnchor).pose
                virtualX=hit.hitPose.tx()-pose.tx();virtualZ=hit.hitPose.tz()-pose.tz()
            }
            stableSince=0
        }
    }
    private fun selectFromDepth(frame:Frame,x:Float,y:Float){
        Log.i("MeoSpatial","DEPTH_SELECT_ATTEMPT x=$x y=$y")
        val depthHit=frame.hitTest(x,y).firstOrNull {it.trackable is DepthPoint && it.distance in .15f..2.5f}
        if(depthHit!=null){
            val p=depthHit.hitPose
            beginDepthScan(frame,floatArrayOf(p.tx(),p.ty(),p.tz()),depthHit.distance,"hit-test")
            return
        }
        // Google specifies TEXTURE_NORMALIZED for depth, not IMAGE_NORMALIZED.
        val input=SpatialRenderer.buffer(floatArrayOf(x,y))
        val uv=SpatialRenderer.buffer(FloatArray(2))
        frame.transformCoordinates2d(Coordinates2d.VIEW,input,Coordinates2d.TEXTURE_NORMALIZED,uv)
        val imagePoint=SpatialRenderer.buffer(FloatArray(2))
        frame.transformCoordinates2d(Coordinates2d.VIEW,SpatialRenderer.buffer(floatArrayOf(x,y)),Coordinates2d.IMAGE_PIXELS,imagePoint)
        var available=false
        for(raw in listOf(true,false))try{
            val image=if(raw)frame.acquireRawDepthImage16Bits() else frame.acquireDepthImage16Bits()
            image.use {depth->
                available=true
                val u=(uv.get(0)*depth.width).toInt()
                val v=(uv.get(1)*depth.height).toInt()
                if(u !in 0 until depth.width || v !in 0 until depth.height)return@use
                val plane=depth.planes[0];val data=plane.buffer.order(java.nio.ByteOrder.nativeOrder())
                val samples=ArrayList<Int>()
                var nonzero=0;var nearest=65535;var farthest=0
                val patch=if(raw)5 else 2
                for(dy in -patch..patch)for(dx in -patch..patch){
                    val sx=u+dx;val sy=v+dy
                    if(sx !in 0 until depth.width || sy !in 0 until depth.height)continue
                    val value=data.getShort(sy*plane.rowStride+sx*plane.pixelStride).toInt() and 65535
                    if(value>0){nonzero++;nearest=min(nearest,value);farthest=max(farthest,value)}
                    if(value in 150..2500)samples.add(value)
                }
                Log.i("MeoSpatial","DEPTH_SELECT_PIXELS raw=$raw u=$u v=$v valid=${samples.size} nonzero=$nonzero range=$nearest..$farthest")
                if(samples.size<(if(raw)3 else 5))return@use
                samples.sort();val distance=samples[samples.size/2]*.001f
                val intr=frame.camera.imageIntrinsics;val f=intr.focalLength;val c=intr.principalPoint
                val px=(imagePoint.get(0)-c[0])*distance/f[0]
                val py=-(imagePoint.get(1)-c[1])*distance/f[1]
                val point=frame.camera.pose.transformPoint(floatArrayOf(px,py,-distance))
                beginDepthScan(frame,point,distance,if(raw)"raw-image" else "dense-image")
            }
            if(capturing)return
        }catch(_:NotYetAvailableException){}
        lastFrameMessage=if(available)
            "Điểm chọn chưa có depth đáng tin cậy. Di chuyển camera sang ngang khoảng 20–30 cm, hướng vào vật thể có chi tiết rồi bấm Bắt đầu quét."
            else "Depth chưa sẵn sàng. Di chuyển camera sang ngang vài giây rồi thử lại."
        Log.i("MeoSpatial","DEPTH_SELECT_REJECTED available=$available")
        postStatus("Chưa đo được vật thể",lastFrameMessage)
    }
    private fun beginDepthScan(frame:Frame,point:FloatArray,distance:Float,source:String){
        if(distance !in .25f..1.2f){lastFrameMessage="Khoảng cách đo được ${(distance*100).toInt()} cm. Đưa camera về khoảng 30–100 cm rồi thử lại.";return}
        val camera=frame.camera.pose
        val dx=point[0]-camera.tx();val dz=point[2]-camera.tz()
        val horizontal=sqrt(dx*dx+dz*dz).coerceAtLeast(.001f)
        // This is a crop around a measured point, never replacement geometry.
        val support=session?.getAllTrackables(Plane::class.java)?.filter {
            it.trackingState==TrackingState.TRACKING && it.subsumedBy==null &&
            it.type==Plane.Type.HORIZONTAL_UPWARD_FACING &&
            point[1]-it.centerPose.ty() in .006f..(radius*2) &&
            it.isPoseInPolygon(Pose.makeTranslation(point[0],it.centerPose.ty(),point[2]))
        }?.maxByOrNull {it.centerPose.ty()}
        if(support==null) {
            lastFrameMessage="Chưa đo chắc mặt đỡ bên dưới vật. Lia chậm qua mép bàn rồi chạm lại vật, hoặc dùng Ảnh → PC. Không đoán đáy vật để tránh ghép cả mặt bàn."
            postStatus("Cần xác định mặt bàn",lastFrameMessage);return
        }
        val base=floatArrayOf(point[0]+dx/horizontal*radius*.2f,support.centerPose.ty(),
            point[2]+dz/horizontal*radius*.2f)
        scanAnchor?.detach();scanAnchor=session?.createAnchor(Pose.makeTranslation(base))
        volume?.close();volume=DepthVolume(radius,base)
        capturing=true;depthReported=true;lastFrameMessage=""
        Log.i("MeoSpatial","DEPTH_OBJECT_SELECTED distance=$distance source=$source")
        runOnUiThread {primary.text="Dừng & tạo mô hình"}
        postStatus("Đang quét vật thể","Vòng xanh phải chứa toàn bộ vật thể. Đi vòng chậm, giữ vật thể đứng yên.")
    }
    private fun drawScan(frame:Frame,vp:FloatArray){
        val v=volume
        if(v==null){
            if(!depthReported)try{frame.acquireRawDepthImage16Bits().use {depth ->
                var nonzero=0
                val plane=depth.planes[0];val bytes=plane.buffer.order(java.nio.ByteOrder.LITTLE_ENDIAN)
                for(y in 0 until depth.height step 4)for(x in 0 until depth.width step 4){
                    if((bytes.getShort(y*plane.rowStride+x*plane.pixelStride).toInt() and 65535) in 150..2500)nonzero++
                }
                if(nonzero>0){depthReported=true;Log.i("MeoSpatial","RAW_DEPTH_AVAILABLE width=${depth.width} height=${depth.height} sampledValid=$nonzero")}
            }}catch(_:NotYetAvailableException){}
            postThrottled(if(lastFrameMessage.isEmpty())"Nhắm vật thể và bấm Bắt đầu quét" else "Chưa chọn được vùng quét",
                lastFrameMessage.ifEmpty {"${if(depthReported)"Depth đã có dữ liệu thật. " else "Di chuyển camera nhẹ sang ngang để khởi tạo depth. "}Có thể chạm trực tiếp vào giữa vật thể; lia thêm qua mặt bàn để nhận mặt đỡ."});return
        }
        if(scanAnchor?.trackingState!=TrackingState.TRACKING){postThrottled("Mất theo dõi vùng quét","Quay lại góc cũ; không di chuyển vật thể.");return}
        val anchorPose=requireNotNull(scanAnchor).pose
        // Integrate in the live anchor frame so ARCore map corrections do not
        // smear an old fixed-world volume into a second copy of the object.
        v.origin[0]=anchorPose.tx();v.origin[1]=anchorPose.ty();v.origin[2]=anchorPose.tz()
        renderer.bounds(vp,v.origin,v.radius)
        val now=SystemClock.elapsedRealtime()
        if(capturing && !busy && now-lastFusion>160){
            lastFusion=now
            var integrated=false
            try{
                frame.acquireRawDepthImage16Bits().use {depth ->
                    if(!depthReported){depthReported=true;Log.i("MeoSpatial","RAW_DEPTH_AVAILABLE width=${depth.width} height=${depth.height}")}
                    frame.acquireRawDepthConfidenceImage().use {confidence ->
                        val color=try {frame.acquireCameraImage()}catch(_:NotYetAvailableException){null}
                        try {integrated=v.integrate(frame,depth,confidence,color,anchorPose)}finally{color?.close()}
                    }
                }
            }catch(_:NotYetAvailableException){lastFrameMessage="Depth đang khởi tạo; di chuyển chậm sang ngang."}
            // Do not substitute interpolated dense depth after a rejected or
            // repeated raw frame: it would count correlated data as new evidence.
            if(integrated && v.frames%10==0)Log.i("MeoSpatial","DEPTH_FUSED frames=${v.frames} coverage=${v.coverage} surface=${v.surfaceUpdates}")
        }
        if(now-lastUi>500){
            lastUi=now
            val low=v.sectors.take(12).mapIndexedNotNull {i,c->if(c<2)i*30 else null}
            val high=v.sectors.drop(12).mapIndexedNotNull {i,c->if(c<2)i*30 else null}
            val message=if(v.frames==0)lastFrameMessage.ifEmpty {"Chờ depth thật; giữ toàn bộ vật thể trong vùng quét."}
                else "${v.hint}\n${v.frames} khung depth · ${v.surfaceUpdates} mẫu bề mặt\nHiện tại: ${v.currentAngle}° · ${if(v.highAngle)"góc cao" else "góc thấp"}\nThiếu góc thấp: ${low.joinToString()}°\nThiếu góc cao: ${high.joinToString()}°\n${if(v.missionReady)"Đủ mục tiêu góc quét; dừng để kiểm tra và tạo lưới." else "Đi vòng chậm quanh bàn, rồi nâng camera để quét mặt trên."}"
            postStatus(if(busy)"Đang tái tạo bề mặt…" else "${if(capturing)"Đang quét" else "Tạm dừng"} · ${v.coverage}% góc",message,v.coverage)
        }
    }
    private fun finishScan(){
        if(photoCapture!=null){finishPhotoScan();return}
        if(busy||!saving.compareAndSet(false,true))return
        capturing=false;busy=true;primary.isEnabled=false
        postStatus("Đang tạo lưới 3D","Trích xuất bề mặt từ các phép đo depth thực; mặt chưa quan sát sẽ không tự được lấp.")
        surface.queueEvent {
            val v=volume
            if(v==null){busy=false;saving.set(false);runOnUiThread {primary.isEnabled=true};return@queueEvent}
            // Fusion is stopped on this GL thread before the worker reads the volume.
            Thread {
                try{
                    val quality=MeshQuality.evaluate(v.mesh())
                    check(quality.acceptable) {"Bề mặt chưa đủ liên tục để lưu. ${quality.summary}. Tiếp tục quét chậm hoặc dùng Ảnh → PC."}
                    val mesh=quality.mesh
                    val complete=v.missionReady && quality.complete
                    val id=ModelStore.save(this,mesh,v.frames,v.coverage,complete,quality=quality.summary)
                    ModelStore.use(this,id)
                    Log.i("MeoSpatial","REAL_RECONSTRUCTION_SAVED id=$id frames=${v.frames} coverage=${v.coverage} triangles=${mesh.triangles}")
                    runOnUiThread {
                        AlertDialog.Builder(this).setTitle(if(complete)"Đạt kiểm tra dữ liệu quét" else "Đã lưu bản quét chưa hoàn chỉnh")
                            .setMessage("${mesh.triangles} tam giác từ ${v.frames} khung depth. ${v.coverage}% góc quét.\n${if(complete)"Đạt kiểm tra dữ liệu tối thiểu; hãy xoay xem lại hình dạng trước khi dùng trong AR." else "Chưa đạt độ phủ hoặc kiểm tra liên tục/cạnh hở. Có thể xem và dùng bản quét này; mặt thiếu vẫn còn lỗ."}")
                            .setPositiveButton("Xem mô hình"){_,_->
                                mode="view";modelId=id;sourceMesh=mesh;aim?.visibility=android.view.View.GONE
                                modelHeight=mesh.vertices.filterIndexed {i,_->i%3==1}.maxOrNull()?.coerceAtLeast(.1f)?:.3f
                                surface.queueEvent {renderer.setMesh(mesh);scanAnchor?.detach();scanAnchor=null}
                                surface.onPause();session?.pause();session?.close();session=null;surface.onResume()
                                busy=false;saving.set(false);primary.isEnabled=true;primary.text="Hướng dẫn";configureControls()
                            }.setNegativeButton("Về thư viện"){_,_->finish()}.setCancelable(false).show()
                    }
                }catch(e:Exception){
                    busy=false;saving.set(false)
                    runOnUiThread{primary.isEnabled=true;primary.text="Tiếp tục quét";showError("Chưa tạo được mô hình",e)}
                }
            }.start()
        }
    }

    private fun startPhotoScan(){
        if(busy || (photoCapture!=null && capturing))return
        surface.queueEvent {
            scanAnchor?.detach();scanAnchor=null;volume?.close();volume=null;photoCapture=PhotoCapture();capturing=true
            runOnUiThread {primary.text="Dừng & tái tạo trên PC"}
            Log.i("MeoSpatial","CONTINUOUS_PHOTO_CAPTURE_STARTED")
        }
    }
    private fun drawPhotoCapture(frame:Frame){
        val capture=photoCapture?:return
        if(capturing && !busy){
            if(capture.add(frame) && capture.count%10==0)Log.i("MeoSpatial","REAL_PHOTOS_CAPTURED count=${capture.count}")
            if(capture.count>=120)capturing=false
        }
        val now=SystemClock.elapsedRealtime()
        if(!busy && now-lastUi>500){
            lastUi=now
            postStatus("Ảnh liên tục · ${capture.count}/120 ảnh thật",
                "${capture.hint}\nGiữ toàn bộ vật thể ở giữa khung, chiếm khoảng 60–70% ảnh.\nDi chuyển quanh vật thể đứng yên; không chỉ xoay tablet tại chỗ.\nÍt nhất 30 ảnh rõ; nên thu 60–120 ảnh ở hai độ cao. Ảnh lấy tự động, không bấm chụp từng tấm.\nNhấn Dừng để gửi tới máy tính cục bộ và tạo mô hình.",capture.count*100/120)
        }
    }
    private fun finishPhotoScan(){
        if(busy || !saving.compareAndSet(false,true))return
        capturing=false;busy=true;primary.isEnabled=false
        surface.queueEvent {
            val capture=photoCapture
            if(capture==null){busy=false;saving.set(false);runOnUiThread {primary.isEnabled=true};return@queueEvent}
            Thread{
                try{
                    val result=capture.reconstruct {p,message->postStatus("Đang tái tạo trên máy tính · $p%",message,p)}
                    val id=ModelStore.save(this,result.mesh,result.frames,result.coverage,result.complete,"photogrammetry",result.job,result.scaleEstimated,result.quality,result.qualityVersion)
                    ModelStore.use(this,id)
                    Log.i("MeoSpatial","REAL_PHOTO_RECONSTRUCTION_SAVED id=$id photos=${result.frames} triangles=${result.mesh.triangles} coverage=${result.coverage}")
                    runOnUiThread {
                        AlertDialog.Builder(this).setTitle(if(result.complete)"Đạt kiểm tra dữ liệu quét" else "Đã lưu bản quét từ ảnh")
                            .setMessage("${result.mesh.triangles} tam giác từ ${result.frames} ảnh camera. ${result.coverage}% góc.\n${if(result.scaleEstimated)"Tỷ lệ mét chưa đủ tin cậy; kích thước chỉ là ước lượng." else "Tỷ lệ từ camera ARCore; chưa phải phép đo hiệu chuẩn."} ${if(result.complete)"" else "Chưa đạt mục tiêu phủ góc; mặt khuất có thể còn thiếu."}")
                            .setPositiveButton("Xem mô hình"){_,_->
                                mode="view";modelId=id;sourceMesh=result.mesh;aim?.visibility=android.view.View.GONE
                                modelHeight=result.mesh.vertices.filterIndexed {i,_->i%3==1}.maxOrNull()?.coerceAtLeast(.1f)?:.3f
                                surface.onPause();session?.pause();session?.close();session=null
                                surface.queueEvent {renderer.setMesh(result.mesh)};surface.onResume()
                                busy=false;saving.set(false);primary.isEnabled=true;primary.text="Hướng dẫn";configureControls()
                            }.setNegativeButton("Về thư viện"){_,_->finish()}.setCancelable(false).show()
                    }
                }catch(e:Exception){busy=false;saving.set(false);runOnUiThread {primary.isEnabled=true;primary.text="Tiếp tục thu ảnh";showError("Chưa tái tạo được mô hình",e)}}
            }.start()
        }
    }

    private fun drawAr(frame:Frame,vp:FloatArray){
        if(busy)return
        val anchor=targetAnchor
        if(anchor==null){
            val planes=session?.getAllTrackables(Plane::class.java)?.filter {
                it.trackingState==TrackingState.TRACKING && it.subsumedBy==null && it.type==Plane.Type.HORIZONTAL_UPWARD_FACING
            }?:emptyList()
            for(plane in planes.take(6))renderer.plane(vp,plane)
            postThrottled("Sắp đặt AR · 0/3","${planes.size} mặt phẳng đã nhận diện. Chạm trong viền xanh hoặc góc có họa tiết để đặt tại điểm 3D thật.");return
        }
        if(anchor.trackingState!=TrackingState.TRACKING || (placementAnchor!=null && placementAnchor?.trackingState!=TrackingState.TRACKING)){
            stableSince=0;postThrottled("Đang tìm lại mặt bàn","Quay camera lại vùng đã đặt mô hình.");return
        }
        val p=anchor.pose
        val targetYaw=levels[round.coerceAtMost(2)];val targetScale=targetScales[round.coerceAtMost(2)]
        val actualY=placementAnchor?.pose?.ty()?:p.ty()
        val actualX=placementAnchor?.pose?.tx()?: (p.tx()+virtualX)
        val actualZ=placementAnchor?.pose?.tz()?: (p.tz()+virtualZ)
        renderer.mesh(vp,SpatialRenderer.model(actualX,actualY,actualZ,yaw,scale))
        renderer.mesh(vp,SpatialRenderer.model(p.tx(),p.ty(),p.tz(),targetYaw,targetScale),floatArrayOf(.1f,1f,.7f,.35f))
        val distance=sqrt((actualX-p.tx()).pow(2)+(actualZ-p.tz()).pow(2)+(actualY-p.ty()).pow(2))
        val angle=abs(((yaw-targetYaw)%360+540)%360-180)
        val scaleError=abs(scale/targetScale-1)
        val now=SystemClock.elapsedRealtime()
        val matched=distance<.06f && angle<12 && scaleError<.12f
        if(matched && !completed.get()){
            if(stableSince==0L)stableSince=now
            if(now-stableSince>=2000){
                round++;stableSince=0;virtualX=.35f;virtualZ=0f;yaw=0f;scale=1f
                placementAnchor?.detach();placementAnchor=null
                if(round>=3 && completed.compareAndSet(false,true)){
                    persistCompletion("ar")
                }
            }
        }else stableSince=0
        if(now-lastUi>400){lastUi=now;postStatus(if(completed.get())"Hoàn thành Sắp đặt AR · 3/3" else "Sắp đặt AR · ${round}/3",
            "Lệch ${(distance*100).toInt()} cm · ${angle.toInt()}° · ${(scaleError*100).toInt()}% cỡ\nĐích: ${targetYaw.toInt()}° · ${(targetScale*100).toInt()}%\n${if(matched)"Giữ đúng vị trí 2 giây…" else "Chạm bàn để di chuyển; vuốt xoay; chụm đổi cỡ."}",round.coerceAtMost(3)*100/3)}
    }

    private val collected=BooleanArray(4)
    private val stationPositions=arrayOf(floatArrayOf(.65f,.12f,0f),floatArrayOf(0f,.12f,-.65f),floatArrayOf(-.65f,.12f,0f),floatArrayOf(0f,.12f,.65f))
    private fun drawVirtual(){
        if(busy)return
        val mesh=sourceMesh?:return
        val maxHeight=modelHeight
        val localYaw=if(headTracking)headYaw else yaw
        val localPitch=if(headTracking)headPitch else pitch
        val angle=Math.toRadians(localYaw.toDouble()).toFloat()
        val elev=Math.toRadians(localPitch.toDouble()).toFloat()
        val eyeX=if(mode=="view")sin(angle)*cameraDistance*cos(elev) else virtualX
        val eyeY=if(mode=="view")maxHeight/2+sin(elev)*cameraDistance else maxHeight/2+.18f
        val eyeZ=if(mode=="view")cos(angle)*cameraDistance*cos(elev) else cameraDistance+virtualZ
        val lookingX=if(mode=="view")0f else eyeX-sin(angle)*cos(elev)
        val lookingY=if(mode=="view")maxHeight/2 else eyeY-sin(elev)
        val lookingZ=if(mode=="view")0f else eyeZ-cos(angle)*cos(elev)
        val views=if(stereo)2 else 1
        var lookingStation=-1
        for(eye in 0 until views){
            val w=width/views;G.glViewport(eye*w,0,w,height)
            val offset=if(views==1)0f else if(eye==0)-.032f else .032f
            val v=FloatArray(16);val p=FloatArray(16);val vp=FloatArray(16)
            Matrix.setLookAtM(v,0,eyeX+offset*cos(angle),eyeY,eyeZ-offset*sin(angle),lookingX+offset*cos(angle),lookingY,lookingZ-offset*sin(angle),0f,1f,0f)
            Matrix.perspectiveM(p,0,58f,w.toFloat()/height,.03f,30f);Matrix.multiplyMM(vp,0,p,0,v,0)
            renderer.grid(vp);renderer.mesh(vp,SpatialRenderer.model(0f,0f,0f,0f,if(mode=="view")1f else scale))
            if(mode=="vr")for(i in stationPositions.indices){
                val s=stationPositions[i]
                // Stations use a scaled copy of the user's actual scanned mesh, not a demo object.
                renderer.mesh(vp,SpatialRenderer.model(s[0],s[1],s[2],0f,.18f),
                    if(collected[i])floatArrayOf(.2f,.3f,.35f,1f) else floatArrayOf(1f,.7f,.15f,1f))
                val dx=s[0]-eyeX;val dy=s[1]+maxHeight*.09f-eyeY;val dz=s[2]-eyeZ
                val distance=sqrt(dx*dx+dy*dy+dz*dz)
                val fx=lookingX-eyeX;val fy=lookingY-eyeY;val fz=lookingZ-eyeZ
                val fl=sqrt(fx*fx+fy*fy+fz*fz)
                if(!collected[i] && distance<.9f && (dx*fx+dy*fy+dz*fz)/(distance*fl)>.94f)lookingStation=i
            }
        }
        if(mode=="vr"){
            if(tap!=null){tap=null;if(lookingStation>=0)collected[lookingStation]=true}
            val count=collected.count {it}
            if(count==4 && completed.compareAndSet(false,true))persistCompletion("vr")
            val now=SystemClock.elapsedRealtime()
            if(now-lastUi>400){lastUi=now;postStatus(if(count==4)"Hoàn thành Thám hiểm VR · 4/4" else "Thám hiểm VR · $count/4",
                "${if(lookingStation>=0)"Đã ngắm trạm ${lookingStation+1}: chạm để thu thập." else "Di chuyển gần trạm vàng rồi hướng tâm nhìn vào trạm."}\n${if(stereo)"Kính điện thoại · theo dõi hướng" else "Không gian 3D · điều khiển bằng chạm"}",count*25)}
        }else postThrottled("Mô hình thật · ${mesh.triangles} tam giác","Vuốt xoay · chụm phóng to · dữ liệu quét được lưu trên thiết bị")
    }
    private fun persistCompletion(game:String){
        val id=modelId?:return
        Thread {try{ModelStore.complete(this,id,game);Log.i("MeoSpatial","MISSION_COMPLETE mode=$game id=$id")}
        catch(e:Exception){Log.e("MeoSpatial","Cannot persist completion",e);postStatus("Đã hoàn thành nhưng chưa lưu được",e.message?:"Lỗi lưu trữ")}}.start()
    }
    private fun exportModel(){
        if(modelId==null)return
        val textured=sourceMesh?.texture!=null
        val intent=android.content.Intent(android.content.Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(android.content.Intent.CATEGORY_OPENABLE);type="application/octet-stream"
            putExtra(android.content.Intent.EXTRA_TITLE,"meomeo-scan-${modelId}.${if(textured)"obj.zip" else "ply"}")
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent,55)
    }
    @Deprecated("Android document picker callback")
    override fun onActivityResult(requestCode:Int,resultCode:Int,data:android.content.Intent?){
        super.onActivityResult(requestCode,resultCode,data)
        if(requestCode!=55 || resultCode!=RESULT_OK)return
        val uri=data?.data?:return;val id=modelId?:return
        Thread{try{
            val output=requireNotNull(contentResolver.openOutputStream(uri))
            output.use {out->java.io.File(filesDir,"spatial_models/$id.${if(sourceMesh?.texture!=null)"obj.zip" else "ply"}").inputStream().use {it.copyTo(out)}}
            runOnUiThread {Toast.makeText(this,"Đã xuất mô hình và texture nếu có",Toast.LENGTH_LONG).show()}
        }catch(e:Exception){runOnUiThread{showError("Không xuất được PLY",e)}}}.start()
    }
    private fun postThrottled(title:String,message:String){val now=SystemClock.elapsedRealtime();if(now-lastUi>600){lastUi=now;postStatus(title,message)}}
    private fun postStatus(title:String,message:String,value:Int?=null){runOnUiThread{if(!isFinishing){status.text=title;detail.text=message;value?.let{progress.progress=it}}}}
    private fun showError(title:String,e:Exception){Log.e("MeoSpatial",title,e);postStatus(title,e.message?:e.javaClass.simpleName)
        if(!isFinishing)AlertDialog.Builder(this).setTitle(title).setMessage(e.message?:e.javaClass.simpleName).setPositiveButton("Đóng",null).show()}
    override fun onSensorChanged(event:SensorEvent){
        if(!headTracking)return
        val matrix=FloatArray(9);val orientation=FloatArray(3)
        SensorManager.getRotationMatrixFromVector(matrix,event.values)
        SensorManager.getOrientation(matrix,orientation)
        val heading=Math.toDegrees(orientation[0].toDouble()).toFloat()
        val tilt=-Math.toDegrees(orientation[1].toDouble()).toFloat()
        if(headReference==null)headReference=heading-yaw
        if(headPitchReference==null)headPitchReference=tilt-pitch
        headYaw=heading-requireNotNull(headReference)
        headPitch=(tilt-requireNotNull(headPitchReference)).coerceIn(-70f,70f)
    }
    override fun onAccuracyChanged(sensor:Sensor?,accuracy:Int){}
}
