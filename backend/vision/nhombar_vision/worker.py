import logging
import multiprocessing as mp
import threading
from .inference import worker_loop
from .settings import INFERENCE_TIMEOUT

log = logging.getLogger(__name__)


class VisionFailure(Exception):
    def __init__(self, code):
        self.code = code


class ProcessDetector:
    def __init__(self, timeout=INFERENCE_TIMEOUT):
        self.timeout = timeout
        self._lock = threading.Lock()
        self._process = None
        self._pipe = None
        self._closed = False
        self._ready = False

    @property
    def ready(self):
        process = self._process
        if not self._ready or process is None:
            return False
        try:
            return process.is_alive()
        except ValueError:  # Health check raced with closing a failed worker.
            return False

    def start(self):
        with self._lock:
            if self._closed:
                return
            self._stop()
            context = mp.get_context('spawn')
            parent, child = context.Pipe()
            self._pipe = parent
            self._process = context.Process(target=worker_loop, args=(child,), daemon=True)
            try:
                self._process.start()
                child.close()
                if not parent.poll(90) or parent.recv() != {'ready': True}:
                    raise RuntimeError('YOLO model did not become ready')
                self._ready = True
            except Exception:
                child.close()
                self._stop()
                raise

    def _stop(self):
        self._ready = False
        if self._process is not None:
            if self._process.pid is not None:
                if self._process.is_alive():
                    self._process.terminate()
                self._process.join(timeout=3)
                if self._process.is_alive():
                    self._process.kill()
                    self._process.join(timeout=3)
            self._process.close()
            self._process = None
        if self._pipe is not None:
            self._pipe.close()
            self._pipe = None

    def _recover(self):
        try:
            self.start()
        except Exception:
            log.exception('YOLO worker restart failed')

    def detect(self, payload, mime):
        if not self._lock.acquire(blocking=False):
            raise VisionFailure('busy')
        try:
            if not self.ready:
                raise VisionFailure('not_ready')
            try:
                self._pipe.send((payload, mime))
                if not self._pipe.poll(self.timeout):
                    raise TimeoutError()
                response = self._pipe.recv()
            except (TimeoutError, EOFError, OSError):
                log.warning('YOLO worker timed out or lost connection; restarting')
                self._stop()
                threading.Thread(target=self._recover, daemon=True).start()
                raise VisionFailure('inference_timeout') from None
            if 'error' in response:
                raise VisionFailure(response['error'])
            return response['result']
        finally:
            self._lock.release()

    def close(self):
        self._closed = True
        with self._lock:
            self._stop()
