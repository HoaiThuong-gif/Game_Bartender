package com.example.nhom_bar.spatial

/** Keep reconstruction diagnostics in logs and instructions short on camera. */
object ScanMessages {
    fun captureHint(raw:String):String = when {
        raw.contains("nhảy") || raw.contains("không hợp lệ") -> "Hãy chọn lại và quét chậm hơn."
        raw.contains("nhanh") || raw.contains("mờ") -> "Giữ tay chắc và đi chậm hơn nhé."
        raw.contains("sáng") -> "Đưa đồ vật đến chỗ đủ sáng."
        raw.contains("Khoảng cách") -> "Đến gần hơn để nhìn rõ toàn bộ đồ vật."
        raw.contains("đủ ảnh") -> "Đi tiếp sang bên cạnh hoặc phía sau đồ vật."
        raw.contains("tracking",true) || raw.contains("đồng bộ") -> "Giữ máy yên một chút để nhìn rõ đồ vật."
        else -> "Giữ đồ vật đứng yên, đi chậm để nhìn đủ các mặt."
    }
}
