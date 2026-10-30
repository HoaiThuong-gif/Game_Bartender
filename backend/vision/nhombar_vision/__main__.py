import uvicorn

if __name__ == '__main__':
    # Loopback only. Samsung connects through adb reverse tcp:8766 tcp:8766.
    # One HTTP worker owns one isolated inference process; never expose publicly.
    uvicorn.run('nhombar_vision.api:app', host='127.0.0.1', port=8766,
                workers=1, limit_concurrency=8, timeout_keep_alive=5)
