package com.example.nhom_bar.spatial

import android.opengl.GLES11Ext
import android.opengl.GLES20 as G
import android.opengl.Matrix
import android.opengl.GLUtils
import android.graphics.BitmapFactory
import com.google.ar.core.Coordinates2d
import com.google.ar.core.Frame
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import kotlin.math.*

/** GLES renderer shared by the real camera, the saved mesh and the virtual mission. */
class SpatialRenderer {
    var cameraTexture = 0; private set
    private var cameraProgram = 0
    private var meshProgram = 0
    private val quad = buffer(floatArrayOf(-1f,-1f,1f,-1f,-1f,1f,1f,1f))
    private val uv = buffer(FloatArray(8))
    private var geometry: FloatBuffer? = null
    private var vertexCount = 0
    private var modelTexture = 0
    private val grid = buffer(buildList<Float> {
        for (i in -10..10) {
            val t = i*.25f
            addAll(listOf(t,0f,-2.5f,t,0f,2.5f,-2.5f,0f,t,2.5f,0f,t))
        }
    }.toFloatArray())

    fun initialize() {
        cameraProgram = program("attribute vec2 p; attribute vec2 uv; varying vec2 t; void main(){gl_Position=vec4(p,0.,1.);t=uv;}",
            "#extension GL_OES_EGL_image_external : require\nprecision mediump float; uniform samplerExternalOES image; varying vec2 t; void main(){gl_FragColor=texture2D(image,t);}")
        meshProgram = program("uniform mat4 mvp; attribute vec3 p; attribute vec3 color; attribute vec3 normal; attribute vec2 texCoord; varying vec3 c; varying vec2 tex; varying float light; void main(){gl_Position=mvp*vec4(p,1.);c=color;tex=texCoord;light=.65+.35*abs(dot(normalize(normal),normalize(vec3(.4,.8,.6))));}",
            "precision mediump float; uniform vec4 tint; uniform sampler2D atlas; uniform float textured; varying vec3 c; varying vec2 tex; varying float light; void main(){vec3 base=textured>.5?texture2D(atlas,vec2(tex.x,1.-tex.y)).rgb:c;vec3 rgb=tint.a<0.?base:tint.rgb;gl_FragColor=vec4(rgb*light,abs(tint.a));}")
        modelTexture=0
        val names = IntArray(1); G.glGenTextures(1,names,0); cameraTexture=names[0]
        G.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,cameraTexture)
        G.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,G.GL_TEXTURE_MIN_FILTER,G.GL_LINEAR)
        G.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,G.GL_TEXTURE_MAG_FILTER,G.GL_LINEAR)
        G.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,G.GL_TEXTURE_WRAP_S,G.GL_CLAMP_TO_EDGE)
        G.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,G.GL_TEXTURE_WRAP_T,G.GL_CLAMP_TO_EDGE)
    }
    fun setMesh(mesh: ScanMesh) {
        val v = mesh.vertices; val packed = FloatArray(v.size/3*11)
        for (i in v.indices step 9) {
            val ax=v[i+3]-v[i];val ay=v[i+4]-v[i+1];val az=v[i+5]-v[i+2]
            val bx=v[i+6]-v[i];val by=v[i+7]-v[i+1];val bz=v[i+8]-v[i+2]
            val nx=ay*bz-az*by;val ny=az*bx-ax*bz;val nz=ax*by-ay*bx
            val length=sqrt(nx*nx+ny*ny+nz*nz).coerceAtLeast(.000001f)
            for (j in 0..2) {
                val p=i+j*3;val out=p/3*11
                for(k in 0..2) {packed[out+k]=v[p+k];packed[out+3+k]=mesh.colors[p+k]/255f}
                packed[out+6]=nx/length;packed[out+7]=ny/length;packed[out+8]=nz/length
                packed[out+9]=mesh.uv?.get(p/3*2)?:0f
                packed[out+10]=mesh.uv?.get(p/3*2+1)?:0f
            }
        }
        geometry=buffer(packed);vertexCount=v.size/3
        if(modelTexture!=0)G.glDeleteTextures(1,intArrayOf(modelTexture),0)
        modelTexture=0
        if(mesh.texture!=null && mesh.uv!=null) {
            val bitmap=requireNotNull(BitmapFactory.decodeByteArray(mesh.texture,0,mesh.texture.size))
            try {
                val names=IntArray(1);G.glGenTextures(1,names,0);modelTexture=names[0]
                G.glBindTexture(G.GL_TEXTURE_2D,modelTexture)
                G.glTexParameteri(G.GL_TEXTURE_2D,G.GL_TEXTURE_MIN_FILTER,G.GL_LINEAR)
                G.glTexParameteri(G.GL_TEXTURE_2D,G.GL_TEXTURE_MAG_FILTER,G.GL_LINEAR)
                G.glTexParameteri(G.GL_TEXTURE_2D,G.GL_TEXTURE_WRAP_S,G.GL_CLAMP_TO_EDGE)
                G.glTexParameteri(G.GL_TEXTURE_2D,G.GL_TEXTURE_WRAP_T,G.GL_CLAMP_TO_EDGE)
                GLUtils.texImage2D(G.GL_TEXTURE_2D,0,bitmap,0)
            } finally {bitmap.recycle()}
        }
    }
    fun camera(frame: Frame) {
        quad.position(0);uv.position(0)
        frame.transformCoordinates2d(Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
            quad,Coordinates2d.TEXTURE_NORMALIZED,uv)
        G.glDisable(G.GL_DEPTH_TEST);G.glDepthMask(false);G.glUseProgram(cameraProgram)
        G.glActiveTexture(G.GL_TEXTURE0);G.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,cameraTexture)
        G.glUniform1i(G.glGetUniformLocation(cameraProgram,"image"),0)
        attribute(cameraProgram,"p",quad,2,0,0);attribute(cameraProgram,"uv",uv,2,0,0)
        G.glDrawArrays(G.GL_TRIANGLE_STRIP,0,4)
        G.glDepthMask(true);G.glEnable(G.GL_DEPTH_TEST)
    }
    fun mesh(vp: FloatArray, model: FloatArray, tint: FloatArray? = null) {
        val data=geometry?:return
        val mvp=FloatArray(16);Matrix.multiplyMM(mvp,0,vp,0,model,0)
        G.glUseProgram(meshProgram);G.glEnable(G.GL_DEPTH_TEST);G.glDisable(G.GL_CULL_FACE)
        G.glUniformMatrix4fv(G.glGetUniformLocation(meshProgram,"mvp"),1,false,mvp,0)
        G.glUniform4fv(G.glGetUniformLocation(meshProgram,"tint"),1,tint?:floatArrayOf(0f,0f,0f,-1f),0)
        G.glUniform1f(G.glGetUniformLocation(meshProgram,"textured"),if(modelTexture!=0)1f else 0f)
        G.glActiveTexture(G.GL_TEXTURE1);G.glBindTexture(G.GL_TEXTURE_2D,modelTexture)
        G.glUniform1i(G.glGetUniformLocation(meshProgram,"atlas"),1)
        if(tint!=null && tint[3]<1f) {G.glEnable(G.GL_BLEND);G.glBlendFunc(G.GL_SRC_ALPHA,G.GL_ONE_MINUS_SRC_ALPHA);G.glDepthMask(false)}
        attribute(meshProgram,"p",data,3,44,0);attribute(meshProgram,"color",data,3,44,3);attribute(meshProgram,"normal",data,3,44,6)
        attribute(meshProgram,"texCoord",data,2,44,9)
        G.glDrawArrays(G.GL_TRIANGLES,0,vertexCount)
        G.glDepthMask(true);G.glDisable(G.GL_BLEND)
    }
    fun lines(vp: FloatArray, data: FloatBuffer, color: FloatArray) {
        G.glUseProgram(meshProgram)
        G.glUniformMatrix4fv(G.glGetUniformLocation(meshProgram,"mvp"),1,false,vp,0)
        G.glUniform4fv(G.glGetUniformLocation(meshProgram,"tint"),1,color,0)
        G.glUniform1f(G.glGetUniformLocation(meshProgram,"textured"),0f)
        attribute(meshProgram,"p",data,3,0,0)
        for(name in arrayOf("color","normal","texCoord")){val location=G.glGetAttribLocation(meshProgram,name);G.glDisableVertexAttribArray(location);G.glVertexAttrib3f(location,0f,1f,0f)}
        G.glLineWidth(2f);G.glDrawArrays(G.GL_LINES,0,data.capacity()/3)
    }
    fun grid(vp: FloatArray) = lines(vp,grid,floatArrayOf(.15f,.4f,.48f,1f))
    fun plane(vp:FloatArray,plane:com.google.ar.core.Plane){
        val polygon=plane.polygon
        val count=polygon.limit()/2
        if(count<3)return
        val vertices=FloatArray(count*6)
        for(i in 0 until count){
            for(j in 0..1){
                val p=(i+j)%count
                val world=plane.centerPose.transformPoint(floatArrayOf(polygon.get(p*2),.002f,polygon.get(p*2+1)))
                for(k in 0..2)vertices[i*6+j*3+k]=world[k]
            }
        }
        lines(vp,buffer(vertices),floatArrayOf(.2f,1f,.6f,1f))
    }
    fun bounds(vp: FloatArray, origin: FloatArray, radius: Float) {
        val data=ArrayList<Float>()
        fun line(a:FloatArray,b:FloatArray){data.addAll(a.toList());data.addAll(b.toList())}
        for (i in 0..47) {
            val a=i*2*PI/48;val b=(i+1)*2*PI/48
            for(h in floatArrayOf(.008f,radius*2)) line(
                floatArrayOf(origin[0]+cos(a).toFloat()*radius,origin[1]+h,origin[2]+sin(a).toFloat()*radius),
                floatArrayOf(origin[0]+cos(b).toFloat()*radius,origin[1]+h,origin[2]+sin(b).toFloat()*radius))
            if(i%12==0)line(floatArrayOf(origin[0]+cos(a).toFloat()*radius,origin[1],origin[2]+sin(a).toFloat()*radius),
                floatArrayOf(origin[0]+cos(a).toFloat()*radius,origin[1]+radius*2,origin[2]+sin(a).toFloat()*radius))
        }
        lines(vp,buffer(data.toFloatArray()),floatArrayOf(.25f,1f,.8f,1f))
    }
    companion object {
        fun identity() = FloatArray(16).also {Matrix.setIdentityM(it,0)}
        fun model(x:Float,y:Float,z:Float,yaw:Float,scale:Float)=identity().also {
            Matrix.translateM(it,0,x,y,z);Matrix.rotateM(it,0,yaw,0f,1f,0f);Matrix.scaleM(it,0,scale,scale,scale)
        }
        fun buffer(values:FloatArray):FloatBuffer=ByteBuffer.allocateDirect(values.size*4).order(ByteOrder.nativeOrder()).asFloatBuffer().apply {put(values);position(0)}
        private fun attribute(program:Int,name:String,data:FloatBuffer,size:Int,stride:Int,offset:Int){
            val location=G.glGetAttribLocation(program,name);if(location<0)return
            data.position(offset);G.glVertexAttribPointer(location,size,G.GL_FLOAT,false,stride,data);G.glEnableVertexAttribArray(location)
        }
        private fun program(vertex:String,fragment:String):Int {
            fun shader(type:Int,source:String):Int {val id=G.glCreateShader(type);G.glShaderSource(id,source);G.glCompileShader(id);val ok=IntArray(1);G.glGetShaderiv(id,G.GL_COMPILE_STATUS,ok,0);check(ok[0]!=0){G.glGetShaderInfoLog(id)};return id}
            val v=shader(G.GL_VERTEX_SHADER,vertex);val f=shader(G.GL_FRAGMENT_SHADER,fragment)
            val p=G.glCreateProgram();G.glAttachShader(p,v);G.glAttachShader(p,f);G.glLinkProgram(p)
            val ok=IntArray(1);G.glGetProgramiv(p,G.GL_LINK_STATUS,ok,0);check(ok[0]!=0){G.glGetProgramInfoLog(p)}
            G.glDeleteShader(v);G.glDeleteShader(f);return p
        }
    }
}
