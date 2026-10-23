$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$scanPython = Join-Path $projectRoot '.scan-runtime\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $scanPython)) {
    & py -3.11 -m venv (Join-Path $projectRoot '.scan-runtime')
    if ($LASTEXITCODE -ne 0) { throw 'Python 3.11 is required.' }
}
& $scanPython -m pip install --disable-pip-version-check numpy==1.26.4 opencv-python-headless==4.10.0.84 pycolmap==4.2.1 open3d==0.19.0
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
if (-not $env:SPATIAL_SEGMENT_PYTHON) {
    $env:SPATIAL_SEGMENT_PYTHON = (& py -3.11 -c 'import sys;print(sys.executable)').Trim()
}
& $env:SPATIAL_SEGMENT_PYTHON -B (Join-Path $PSScriptRoot 'setup_scan_segmentation.py')
if ($LASTEXITCODE -ne 0) { throw 'Object segmentation setup failed.' }
& $scanPython -B (Join-Path $PSScriptRoot 'setup_scan_mvs.py')
if ($LASTEXITCODE -ne 0) { throw 'Multi-view reconstruction setup failed.' }
& $scanPython -u (Join-Path $PSScriptRoot 'scan_server.py')
