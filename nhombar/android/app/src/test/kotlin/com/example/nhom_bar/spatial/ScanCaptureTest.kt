package com.example.nhom_bar.spatial

import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.ExecutionException
import org.junit.Assert.*
import org.junit.Test

class ScanCaptureTest {
    @Test fun queueKeepsOnlyOneImageAndDrainsBeforeProcessing() {
        val started=CountDownLatch(1);val release=CountDownLatch(1)
        ScanWorkQueue<Int>().use {worker->
            assertTrue(worker.submit {started.countDown();check(release.await(2,TimeUnit.SECONDS));7})
            assertTrue(started.await(2,TimeUnit.SECONDS))
            try {
                assertFalse(worker.submit {99})
                assertNull(worker.takeCompleted()) // A slow encoder must not block the preview.
                assertFalse(worker.available())
            }finally {release.countDown()}
            assertEquals(7,worker.finishPending())
            assertNull(worker.takeCompleted()) // Consume the final frame exactly once.
            assertTrue(worker.available())
            assertTrue(worker.submit {8})
            assertEquals(8,worker.finishPending())
        }
    }

    @Test fun encoderFailureDoesNotLeaveQueuePermanentlyBusy() {
        ScanWorkQueue<Int>().use {worker->
            worker.submit {throw IllegalStateException("encoding failed")}
            try {worker.finishPending();fail("Expected encoder error")}
            catch (_:ExecutionException) {}
            assertTrue(worker.available())
            worker.submit {42}
            assertEquals(42,worker.finishPending())
        }
    }

    @Test fun closingDiscardsWorkAndRejectsNewImages() {
        val worker=ScanWorkQueue<Int>()
        worker.submit {1}
        worker.close()
        assertNull(worker.takeCompleted())
        assertFalse(worker.submit {2})
        assertFalse(worker.available())
    }

    @Test fun snapshotOwnsItsPixelsAndPreservesSourceBufferPosition() {
        val buffer=ByteBuffer.wrap(byteArrayOf(1,2,3,4));buffer.position(2)
        val copy=ScanImagePlane.copy(buffer,2,1)
        buffer.put(0,99)
        assertEquals(2,buffer.position())
        assertEquals(1,copy.value(0,0).toInt())
        assertEquals(4,copy.value(1,1).toInt())
    }

    @Test fun nv21MatchesOriginalWithPaddedAndInterleavedCameraPlanes() {
        val w=8;val h=6
        for (stride in listOf(1,2)) {
            val y=ScanImagePlane(ByteArray(12*h){it.toByte()},12,1)
            val u=ScanImagePlane(ByteArray(12*h/2){(it+50).toByte()},12,stride)
            val v=ScanImagePlane(ByteArray(12*h/2){(it+100).toByte()},12,stride)
            val image=ScanCameraImage(w,h,y,u,v)
            val expected=ByteArray(w*h*3/2)
            for(row in 0 until h)for(col in 0 until w)expected[row*w+col]=y.value(col,row)
            for(row in 0 until h/2)for(col in 0 until w/2) {
                expected[w*h+row*w+col*2]=v.value(col,row)
                expected[w*h+row*w+col*2+1]=u.value(col,row)
            }
            assertArrayEquals(expected,image.nv21())
        }
    }

    @Test fun largeImagesKeepTheOriginalDownsamplingAndDimensions() {
        val w=2050;val h=12
        val y=ScanImagePlane(ByteArray(w*h){it.toByte()},w,1)
        val u=ScanImagePlane(ByteArray(w*h/4){it.toByte()},w/2,1)
        val image=ScanCameraImage(w,h,y,u,u)
        assertEquals(2,image.factor)
        assertEquals(1024,image.outputWidth)
        assertEquals(6,image.outputHeight)
        val packed=image.nv21()
        assertEquals(y.value(100,4),packed[2*1024+50])
        assertEquals(1024*6*3/2,packed.size)
    }

    @Test fun qualityKeepsOriginalAcceptanceThresholds() {
        fun image(luma:Byte)=ScanCameraImage(20,20,
            ScanImagePlane(ByteArray(400){luma},20,1),
            ScanImagePlane(ByteArray(100),10,1),ScanImagePlane(ByteArray(100),10,1))
        // Plain objects must not be mistaken for motion blur.
        assertTrue(image(100).quality().acceptable)
        assertFalse(image(0).quality().acceptable)
        assertFalse(image(255.toByte()).quality().acceptable)
    }
}
