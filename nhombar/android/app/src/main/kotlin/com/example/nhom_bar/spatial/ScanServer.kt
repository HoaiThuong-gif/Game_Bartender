package com.example.nhom_bar.spatial

import android.content.Context
import android.provider.Settings
import org.json.JSONObject
import java.io.IOException
import java.net.URL
import java.net.Socket
import java.net.InetSocketAddress
import java.security.MessageDigest
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import java.util.UUID
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.X509TrustManager

/** Settings and trust apply only to scan connections, never to Firebase or WebViews. */
class ScanServer private constructor(
    private val context:Context, val address:String, private val code:String,
    private val device:String, private var token:String
) {
    val transport get() = if (URL(address).host == "127.0.0.1") "USB" else "Wi-Fi"
    private val fingerprint=code.substringBefore('.')
    private val pairingKey=code.substringAfter('.')
    private val tls=SSLContext.getInstance("TLS").apply {
        init(null,arrayOf<X509TrustManager>(object:X509TrustManager {
            override fun getAcceptedIssuers()=emptyArray<X509Certificate>()
            override fun checkClientTrusted(chain:Array<X509Certificate>,authType:String) {throw CertificateException("Client certificates not supported")}
            override fun checkServerTrusted(chain:Array<X509Certificate>,authType:String) {
                if(chain.size!=1)throw CertificateException("Unexpected PC certificate chain")
                chain[0].checkValidity()
                val actual=MessageDigest.getInstance("SHA-256").digest(chain[0].encoded)
                    .joinToString(""){"%02x".format(it.toInt() and 255)}
                if(!MessageDigest.isEqual(actual.toByteArray(),fingerprint.toByteArray()))
                    throw CertificateException("Chứng chỉ PC đã thay đổi. Nhập lại mã ghép nối trên PC.")
                chain[0].verify(chain[0].publicKey)
            }
        }),null)
    }

    fun connection(path:String):HttpsURLConnection {
        require(path.startsWith('/') && !path.contains(".."))
        return (URL(address+path).openConnection() as HttpsURLConnection).apply {
            sslSocketFactory=tls.socketFactory
            // Default hostname validation stays enabled; the PC certificate has an IP SAN.
            instanceFollowRedirects=false
            connectTimeout=7000;readTimeout=30_000
            setRequestProperty("X-Device-ID",device)
            if(token.isNotBlank())setRequestProperty("Authorization","Bearer $token")
        }
    }

    fun response(connection:HttpsURLConnection):JSONObject {
        val status=connection.responseCode
        val stream=if(status in 200..299)connection.inputStream else connection.errorStream
        val body=stream?.bufferedReader()?.use {it.readText()}?:"{}"
        val json=try {JSONObject(body)}catch(e:org.json.JSONException) {
            throw IOException("Phản hồi PC bị gián đoạn hoặc không đúng giao thức quét.",e)
        }
        if(status !in 200..299)throw ServerError(status,json.optString("error","PC HTTP $status"))
        return json
    }

    fun json(path:String):JSONObject {
        val c=connection(path)
        return try {response(c)}finally {c.disconnect()}
    }

    @Synchronized fun check():JSONObject = try {
        checkConnection()
    } catch(e:java.net.ConnectException) { throw connectionError(e)
    } catch(e:java.net.SocketTimeoutException) { throw connectionError(e)
    } catch(e:java.net.NoRouteToHostException) { throw connectionError(e) }

    private fun connectionError(cause:IOException)=IOException(if(transport=="USB")
        "Mất kết nối USB với PC. Kiểm tra cáp, quyền USB debugging và server đang chạy."
        else "Không truy cập được PC qua Wi-Fi. Điện thoại và PC cần cùng mạng Wi-Fi/LAN; kiểm tra địa chỉ PC, server và quyền qua Firewall.",cause)

    private fun checkConnection():JSONObject {
        if(token.isBlank()) {
            val c=connection("/pair").apply {
                requestMethod="POST"
                setRequestProperty("X-Pairing-Key",pairingKey)
            }
            val pair=try {response(c)}finally {c.disconnect()}
            token=pair.getString("token")
            saveToken(context,address,code,token)
        }
        val health=json("/health")
        check(health.optInt("protocol")>=6){"PC cần phiên bản server quét mới."}
        check(health.optBoolean("ready")){"Đã kết nối PC nhưng thư viện tái tạo chưa sẵn sàng."}
        // Verify device credentials as well as the anonymous health endpoint.
        json("/jobs")
        return health
    }

    class ServerError(val status:Int,message:String):IOException(message)

    companion object {
        private const val PREFS="spatial_wifi"
        fun pair(context:Context,address:String,code:String):ScanServer {
            ensureDevice(context)
            val normalized=normalize(address)
            val pairing=code.filterNot {it.isWhitespace()}
            require(pairing.matches(Regex("[a-f0-9]{64}\\.[A-Za-z0-9_-]{32}")))
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            val candidate=ScanServer(context.applicationContext,normalized,pairing,
                requireNotNull(prefs.getString("device",null)),"")
            // Do not replace a working pairing until certificate, credentials,
            // protocol, reconstruction readiness AND jobs authorization succeed.
            candidate.check()
            save(context,normalized,pairing)
            saveToken(context,normalized,pairing,candidate.token)
            return candidate
        }
        fun ready(context:Context):Pair<ScanServer,JSONObject> {
            try {
                val saved=load(context)
                return saved to saved.check()
            } catch (error:Exception) {
                android.util.Log.w("MeoScanConnection","Saved connection unavailable",error)
                val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
                val code=prefs.getString("code","")?:""
                // No discovery-based trust on a first connection. Use the QR
                // physically displayed on the PC (or the authorized USB path).
                if(!code.matches(Regex("[a-f0-9]{64}\\.[A-Za-z0-9_-]{32}")))throw error
                val id=MessageDigest.getInstance("SHA-256").digest(code.substringAfter('.').toByteArray())
                    .joinToString(""){"%02x".format(it.toInt() and 255)}.take(32)
                val address=ScanDiscovery.find(context,id)?:throw error
                val found=pair(context,address,code)
                return found to found.check()
            }
        }
        @Synchronized private fun ensureDevice(context:Context) {
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            val binding=Settings.Secure.getString(context.contentResolver,Settings.Secure.ANDROID_ID)?:"local"
            // A settings backup restored onto another phone receives a new namespace.
            if(prefs.getString("binding",null)!=binding || !prefs.contains("device"))
                check(prefs.edit().putString("binding",binding).putString("device",UUID.randomUUID().toString()).remove("token").remove("usbToken").commit())
        }
        @Synchronized private fun saveToken(context:Context,address:String,code:String,token:String) {
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            if(prefs.getString("usbAddress","")==address && prefs.getString("usbCode","")==code)
                prefs.edit().putString("usbToken",token).apply()
            if(prefs.getString("address","")==address && prefs.getString("code","")==code)
                prefs.edit().putString("token",token).apply()
        }
        @Synchronized fun settings(context:Context):Map<String,String> {
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            return mapOf("address" to (prefs.getString("address","")?:""),"code" to (prefs.getString("code","")?:""),
                "usbAddress" to (prefs.getString("usbAddress","")?:""))
        }
        @JvmStatic @Synchronized fun saveUsb(context:Context,address:String,code:String) {
            ensureDevice(context)
            val normalized=normalize(address)
            require(URL(normalized).host=="127.0.0.1")
            require(code.matches(Regex("[a-f0-9]{64}\\.[A-Za-z0-9_-]{32}")))
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            val edit=prefs.edit().putString("usbAddress",normalized).putString("usbCode",code)
            if(prefs.getString("usbCode","")!=code || prefs.getString("usbAddress","")!=normalized)edit.remove("usbToken")
            check(edit.commit())
        }
        @Synchronized fun save(context:Context,address:String,code:String) {
            ensureDevice(context)
            val normalized=normalize(address)
            val pairing=code.filterNot {it.isWhitespace()}
            require(pairing.matches(Regex("[a-f0-9]{64}\\.[A-Za-z0-9_-]{32}"))){"Mã ghép nối không hợp lệ. Sao chép nguyên mã PC hiển thị."}
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            val same=prefs.getString("address","")==normalized && prefs.getString("code","")==pairing
            val edit=prefs.edit().putString("address",normalized).putString("code",pairing)
            if(!same)edit.remove("token")
            if(!prefs.contains("device"))edit.putString("device",UUID.randomUUID().toString())
            check(edit.commit()) {"Không lưu được cấu hình PC."}
        }
        fun normalize(value:String):String {
            val url=URL(if(value.trim().contains("://"))value.trim() else "https://${value.trim()}")
            require(url.protocol=="https" && url.userInfo==null && url.query==null && url.ref==null && url.path in listOf("","/")) {"Nhập địa chỉ HTTPS của PC, không có đường dẫn."}
            val octets=url.host.split('.').map {it.toIntOrNull()?:-1}
            require(octets.size==4 && octets.all {it in 0..255} &&
                (octets==listOf(127,0,0,1) || octets[0]==10 || (octets[0]==172 && octets[1] in 16..31) || (octets[0]==192 && octets[1]==168))) {"Chỉ cho phép địa chỉ PC trong mạng nội bộ hoặc 127.0.0.1 qua USB."}
            val port=if(url.port==-1)8765 else url.port
            require(port in 1..65535)
            return "https://${octets.joinToString(".")}:$port"
        }
        fun load(context:Context):ScanServer {
            ensureDevice(context)
            val prefs=context.getSharedPreferences(PREFS,Context.MODE_PRIVATE)
            val address=prefs.getString("address","")?:""
            val code=prefs.getString("code","")?:""
            val usbAddress=prefs.getString("usbAddress","")?:""
            val usbCode=prefs.getString("usbCode","")?:""
            if(usbAddress.isNotBlank() && usbCode.isNotBlank()) {
                try {
                    Socket().use {it.connect(InetSocketAddress("127.0.0.1",URL(usbAddress).port),700)}
                    return ScanServer(context.applicationContext,usbAddress,usbCode,
                        requireNotNull(prefs.getString("device",null)),prefs.getString("usbToken","")?:"")
                } catch (_:IOException) { /* No USB tunnel: use the saved LAN connection. */ }
            }
            check(address.isNotBlank() && code.isNotBlank()){
                "Chưa kết nối PC. Cắm USB, bật USB debugging và chạy server; hoặc cấu hình Wi-Fi với PC cùng mạng." }
            return ScanServer(context.applicationContext,normalize(address),code,
                requireNotNull(prefs.getString("device",null)),prefs.getString("token","")?:"")
        }
    }
}
