package com.example.nhom_bar;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.example.nhom_bar.spatial.SpatialBridge;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(),
            "meomeo/lobby").setMethodCallHandler((call, result) -> {
                if (!call.method.equals("gpuInfo")) { result.notImplemented(); return; }
                new Thread(() -> {
                    try {
                        java.util.Map<String, Object> info = lobbyGpuInfo();
                        runOnUiThread(() -> result.success(info));
                    } catch (Exception error) {
                        runOnUiThread(() -> result.error("GPU_QUERY", error.toString(), null));
                    }
                }, "lobby-gpu-query").start();
            });
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(),
            "meomeo/spatial").setMethodCallHandler((call, result) ->
                SpatialBridge.handle(this, call, result));
    }
    // Isolated EGL pbuffer: never changes the Flutter renderer's current context.
    private static java.util.Map<String, Object> lobbyGpuInfo() {
        android.opengl.EGLDisplay display = android.opengl.EGL14.eglGetDisplay(android.opengl.EGL14.EGL_DEFAULT_DISPLAY);
        int[] version = new int[2];
        if (!android.opengl.EGL14.eglInitialize(display, version, 0, version, 1)) throw new IllegalStateException("eglInitialize");
        android.opengl.EGLContext context = android.opengl.EGL14.EGL_NO_CONTEXT;
        android.opengl.EGLSurface surface = android.opengl.EGL14.EGL_NO_SURFACE;
        try {
            int[] attributes = {android.opengl.EGL14.EGL_RENDERABLE_TYPE, android.opengl.EGL14.EGL_OPENGL_ES2_BIT,
                android.opengl.EGL14.EGL_SURFACE_TYPE, android.opengl.EGL14.EGL_PBUFFER_BIT,
                android.opengl.EGL14.EGL_RED_SIZE, 8, android.opengl.EGL14.EGL_NONE};
            android.opengl.EGLConfig[] configs = new android.opengl.EGLConfig[1];
            int[] count = new int[1];
            if (!android.opengl.EGL14.eglChooseConfig(display, attributes, 0, configs, 0, 1, count, 0) || count[0] == 0) throw new IllegalStateException("eglChooseConfig");
            context = android.opengl.EGL14.eglCreateContext(display, configs[0], android.opengl.EGL14.EGL_NO_CONTEXT,
                new int[]{android.opengl.EGL14.EGL_CONTEXT_CLIENT_VERSION,2,android.opengl.EGL14.EGL_NONE},0);
            surface = android.opengl.EGL14.eglCreatePbufferSurface(display, configs[0],
                new int[]{android.opengl.EGL14.EGL_WIDTH,1,android.opengl.EGL14.EGL_HEIGHT,1,android.opengl.EGL14.EGL_NONE},0);
            if (!android.opengl.EGL14.eglMakeCurrent(display,surface,surface,context)) throw new IllegalStateException("eglMakeCurrent");
            int[] limit = new int[1];
            android.opengl.GLES20.glGetIntegerv(android.opengl.GLES20.GL_MAX_TEXTURE_SIZE,limit,0);
            java.util.Map<String, Object> info = new java.util.HashMap<>();
            info.put("maxTextureSize",limit[0]);
            info.put("renderer",android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_RENDERER));
            return info;
        } finally {
            android.opengl.EGL14.eglMakeCurrent(display,android.opengl.EGL14.EGL_NO_SURFACE,android.opengl.EGL14.EGL_NO_SURFACE,android.opengl.EGL14.EGL_NO_CONTEXT);
            if (surface != android.opengl.EGL14.EGL_NO_SURFACE) android.opengl.EGL14.eglDestroySurface(display,surface);
            if (context != android.opengl.EGL14.EGL_NO_CONTEXT) android.opengl.EGL14.eglDestroyContext(display,context);
            // The default EGLDisplay may also belong to Flutter. Destroy only
            // this query's context/surface; terminating it could stop rendering.
            android.opengl.EGL14.eglReleaseThread();
        }
    }

}
