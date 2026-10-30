package com.example.nhom_bar.spatial

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Debug-only receiver; DUMP permission restricts provisioning to adb shell/system. */
class ScanUsbReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "com.example.nhom_bar.SCAN_USB") return
        try {
            ScanServer.saveUsb(context, intent.getStringExtra("address") ?: "",
                intent.getStringExtra("code") ?: "")
            val lanAddress = intent.getStringExtra("lanAddress") ?: ""
            if (lanAddress.isNotBlank()) {
                ScanServer.save(context, lanAddress, intent.getStringExtra("code") ?: "")
            }
            resultCode = 1
        } catch (_: Exception) { resultCode = 0 }
    }
}
