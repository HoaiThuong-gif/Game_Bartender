package com.example.nhom_bar.spatial

import com.google.ar.core.Frame
import com.google.ar.core.Pose
import com.google.ar.core.TrackingState
import kotlin.math.*

/** Reject motion blur/tracking recovery and redundant views before reconstruction. */
class ScanFrameGate {
    private var previous: Pose? = null
    private var accepted: Pose? = null
    private var timestamp = 0L
    private var stableSince = 0L
    private var invalidTrajectory = false
    var message = "Giữ camera ổn định để khởi tạo theo dõi."; private set

    fun accept(frame: Frame, pose: Pose = frame.camera.pose): Boolean {
        val now = frame.timestamp
        if(invalidTrajectory) return false
        if (frame.camera.trackingState != TrackingState.TRACKING) {
            stableSince = 0; previous = null
            message = "Tracking yếu (${frame.camera.trackingFailureReason}): tăng ánh sáng, quay lại góc đã thấy và di chuyển chậm."
            return false
        }
        // LATEST_CAMERA_IMAGE may return the same observation on several GL
        // draws. It must not restart the stability timer or count as motion.
        if (previous != null && now == timestamp) return false
        val last = previous
        val dt = (now - timestamp) * 1e-9f
        previous = pose; timestamp = now
        if(pose.translation.any {!it.isFinite() || abs(it)>50f}) {
            invalidTrajectory=true
            message="Pose camera không hợp lệ. Thoát camera và mở lại để bắt đầu phiên quét mới."
            return false
        }
        if (last == null || dt <= 0 || dt > 1f) {
            stableSince = now; message = "Đợi tracking ổn định khoảng nửa giây."; return false
        }
        val motion = distance(last, pose)
        val angle = angle(last, pose)
        if (motion / dt > .25f || angle / dt > 45f || motion > .08f) {
            stableSince = now; message = "Di chuyển quá nhanh; giữ vật đứng yên và đi chậm hơn."; return false
        }
        if (now - stableSince < 500_000_000L) return false
        val key = accepted
        if(key!=null && distance(key,pose)>.30f) {
            invalidTrajectory=true
            message="Quỹ đạo camera bị nhảy hoặc mất chồng lấp. Thoát camera, mở lại và quét chậm hơn."
            return false
        }
        if (key != null && distance(key, pose) < .008f && angle(key, pose) < 2f) {
            message = "Cần dịch chuyển quanh vật thể để có góc mới, không chỉ giữ camera tại chỗ."
            return false
        }
        accepted = pose; message = "Đang nhận góc nhìn ổn định."
        return true
    }

    fun reset() {previous=null;stableSince=0;invalidTrajectory=false}

    companion object {
        fun distance(a: Pose, b: Pose) = sqrt((a.tx()-b.tx()).pow(2)+(a.ty()-b.ty()).pow(2)+(a.tz()-b.tz()).pow(2))
        fun angle(a: Pose, b: Pose): Float {
            val x = a.rotationQuaternion; val y = b.rotationQuaternion
            val dot = abs(x.indices.sumOf { (x[it]*y[it]).toDouble() }).coerceIn(0.0, 1.0)
            return Math.toDegrees(2*acos(dot)).toFloat()
        }
    }
}
