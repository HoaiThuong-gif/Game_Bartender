package com.example.nhom_bar.spatial

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.util.Log
import java.net.Inet4Address
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/** Discovery is only an address hint. ScanServer still validates TLS and auth. */
object ScanDiscovery {
    @Suppress("DEPRECATION")
    fun find(context: Context, serverId: String): String? {
        val manager = context.getSystemService(Context.NSD_SERVICE) as NsdManager
        val done = CountDownLatch(1)
        val resolving = AtomicBoolean(false)
        var address: String? = null
        val listener = object : NsdManager.DiscoveryListener {
            override fun onDiscoveryStarted(type: String) {}
            override fun onDiscoveryStopped(type: String) {}
            override fun onServiceLost(info: NsdServiceInfo) {}
            override fun onStartDiscoveryFailed(type: String, code: Int) { done.countDown() }
            override fun onStopDiscoveryFailed(type: String, code: Int) {}
            override fun onServiceFound(info: NsdServiceInfo) {
                if (!info.serviceName.startsWith("MeoMeo-${serverId.take(8)}") || !resolving.compareAndSet(false, true)) return
                manager.resolveService(info, object : NsdManager.ResolveListener {
                    override fun onResolveFailed(service: NsdServiceInfo, code: Int) { resolving.set(false) }
                    override fun onServiceResolved(service: NsdServiceInfo) {
                        val id = service.attributes["id"]?.toString(Charsets.UTF_8)
                        val host = service.host
                        if (id == serverId && host is Inet4Address) {
                            try { address = ScanServer.normalize("https://${host.hostAddress}:${service.port}") }
                            catch (_: Exception) { /* Never connect to public/invalid discovered addresses. */ }
                            done.countDown()
                        }
                        resolving.set(false)
                    }
                })
            }
        }
        try {
            manager.discoverServices("_meomeo-scan._tcp.", NsdManager.PROTOCOL_DNS_SD, listener)
            done.await(3500, TimeUnit.MILLISECONDS)
        } catch (error: Exception) {
            Log.w("MeoScanDiscovery", "Discovery unavailable", error)
        } finally {
            try { manager.stopServiceDiscovery(listener) } catch (_: Exception) {}
        }
        return address
    }
}
