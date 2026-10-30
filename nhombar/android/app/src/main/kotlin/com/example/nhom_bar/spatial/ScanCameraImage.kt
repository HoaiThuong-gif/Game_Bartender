package com.example.nhom_bar.spatial

import java.nio.ByteBuffer
import kotlin.math.sqrt

/** Owns a copy of CPU camera planes, so no Image/ARCore Frame reaches a worker. */
data class ScanImagePlane(val bytes: ByteArray, val rowStride: Int, val pixelStride: Int) {
    fun value(x: Int, y: Int) = bytes[y * rowStride + x * pixelStride]

    companion object {
        fun copy(buffer: ByteBuffer, rowStride: Int, pixelStride: Int): ScanImagePlane {
            val source = buffer.duplicate().apply { rewind() }
            return ScanImagePlane(ByteArray(source.remaining()).also { source.get(it) }, rowStride, pixelStride)
        }
    }
}

data class ScanCameraImage(
    val width: Int, val height: Int,
    val y: ScanImagePlane, val u: ScanImagePlane, val v: ScanImagePlane
) {
    // Preserve the existing capture dimensions and calibration scaling.
    val factor get() = if (width > 2048) 2 else 1
    val outputWidth get() = (width / factor) / 2 * 2
    val outputHeight get() = (height / factor) / 2 * 2

    fun nv21(): ByteArray {
        val w = outputWidth; val h = outputHeight
        val result = ByteArray(w * h * 3 / 2)
        for (row in 0 until h) {
            if (factor == 1 && y.pixelStride == 1) {
                System.arraycopy(y.bytes, row * y.rowStride, result, row * w, w)
            } else {
                for (col in 0 until w) result[row * w + col] = y.value(col * factor, row * factor)
            }
        }
        for (row in 0 until h / 2) for (col in 0 until w / 2) {
            val out = w * h + row * w + col * 2
            result[out] = v.value(col * factor, row * factor)
            result[out + 1] = u.value(col * factor, row * factor)
        }
        return result
    }

    data class Quality(val sharpness: Double, val contrast: Double, val clippedFraction: Double) {
        val acceptable get() = !((sharpness < 18 && contrast > 12) || clippedFraction > .35)
    }

    /** Same crop, sampling and thresholds as the original synchronous capture. */
    fun quality(): Quality {
        var sum = 0.0; var squared = 0.0; var samples = 0
        var clipped = 0; var light = 0.0; var lightSquared = 0.0
        fun luminance(x: Int, row: Int) = y.value(x, row).toInt() and 255
        for (row in height / 5 until height * 4 / 5 step 3) {
            for (x in width / 5 until width * 4 / 5 step 3) {
                val value = luminance(x, row)
                val lap = luminance(x - 1, row) + luminance(x + 1, row) +
                    luminance(x, row - 1) + luminance(x, row + 1) - 4 * value
                sum += lap; squared += lap.toDouble() * lap; samples++
                light += value; lightSquared += value.toDouble() * value
                if (value < 8 || value > 247) clipped++
            }
        }
        require(samples > 0)
        return Quality(squared / samples - (sum / samples) * (sum / samples),
            sqrt((lightSquared / samples - (light / samples) * (light / samples)).coerceAtLeast(0.0)),
            clipped.toDouble() / samples)
    }
}
