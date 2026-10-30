import logging
import multiprocessing as mp
import threading
import time
from .inference import worker_loop
from .settings import INFERENCE_TIMEOUT

log = logging.getLogger(__name__)


class EngineError(Exception):
    pass


class ProcessReconstructor:
    def __init__(self, timeout=INFERENCE_TIMEOUT):
        self.timeout = timeout
        self._process = None
        self._pipe = None
        self._closed = False
        self._ready = False
        self._lock = threading.Lock()

    @property
    def ready(self):
        try:
            return self._ready and self._process is not None and self._process.is_alive()
        except ValueError:
            return False

    def start(self):
        with self._lock:
            if self._closed:
                return
            self._stop()
            context = mp.get_context('spawn')
            self._pipe, child = context.Pipe()
            self._process = context.Process(target=worker_loop, args=(child,), daemon=True)
            try:
                self._process.start()
                child.close()
                if not self._pipe.poll(180) or self._pipe.recv() != {'ready': True}:
                    raise EngineError('not_ready')
                self._ready = True
            except Exception:
                child.close()
                self._stop()
                raise

    def _stop(self):
        self._ready = False
        process, self._process = self._process, None
        if process is not None:
            if process.pid is not None:
                if process.is_alive():
                    process.terminate()
                process.join(5)
                if process.is_alive():
                    process.kill()
                    process.join(5)
            process.close()
        if self._pipe is not None:
            self._pipe.close()
            self._pipe = None

    def _recover(self):
        try:
            self.start()
        except Exception:
            log.exception('TripoSR worker restart failed')

    def generate(self, payload, mime, progress):
        if not self._lock.acquire(blocking=False):
            raise EngineError('busy')
        try:
            if not self.ready:
                raise EngineError('not_ready')
            pipe = self._pipe
            try:
                pipe.send((payload, mime))
                deadline = time.monotonic() + self.timeout
                while True:
                    remaining = deadline - time.monotonic()
                    if remaining <= 0 or not pipe.poll(remaining):
                        raise TimeoutError()
                    message = pipe.recv()
                    if 'stage' in message:
                        progress(message['stage'])
                    elif 'mesh' in message:
                        return message['mesh']
                    else:
                        raise EngineError(message.get('error', 'inference_failed'))
            except (TimeoutError, EOFError, OSError):
                self._stop()
                threading.Thread(target=self._recover, daemon=True).start()
                raise EngineError('inference_timeout') from None
        finally:
            self._lock.release()

    def close(self):
        self._closed = True
        self._stop()
