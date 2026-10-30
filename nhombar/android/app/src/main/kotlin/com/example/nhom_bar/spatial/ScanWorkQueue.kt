package com.example.nhom_bar.spatial

import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.Future

/** One active image, no backlog. The preview never waits for image encoding. */
class ScanWorkQueue<T> : AutoCloseable {
    private val executor = Executors.newSingleThreadExecutor { task ->
        Thread(task, "scan-image-encoder").apply { priority = Thread.NORM_PRIORITY - 1 }
    }
    private var pending: Future<T>? = null
    private var closed = false

    @Synchronized fun available() = !closed && pending == null

    @Synchronized fun submit(task: () -> T): Boolean {
        if (closed || pending != null) return false
        pending = executor.submit(Callable { task() })
        return true
    }

    /** Called by the render thread only after work is done; never blocks it. */
    @Synchronized fun takeCompleted(): T? {
        val work = pending ?: return null
        if (!work.isDone) return null
        pending = null
        return work.get()
    }

    /** Called after capture stops, on the processing thread, not the renderer. */
    fun finishPending(): T? {
        val work = synchronized(this) { pending } ?: return null
        return try { work.get() } finally {
            synchronized(this) { if (pending === work) pending = null }
        }
    }

    @Synchronized override fun close() {
        closed = true
        pending?.cancel(true)
        pending = null
        executor.shutdownNow()
    }
}
