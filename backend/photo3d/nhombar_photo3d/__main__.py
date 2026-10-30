import uvicorn

if __name__ == '__main__':
    uvicorn.run('nhombar_photo3d.api:app', host='127.0.0.1', port=8766,
                workers=1, limit_concurrency=8, timeout_keep_alive=5)
