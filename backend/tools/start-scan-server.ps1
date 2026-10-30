param(
    [string]$BindAddress = '',
    [ValidateRange(1,65535)][int]$Port = 8765
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$scanPython = Join-Path $projectRoot '.scan-runtime\Scripts\python.exe'
# Bind to one connected private interface; never a wildcard or Internet address.
$scanInterfaces = @(Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' -and $_.IPv4DefaultGateway })
$scanCandidates = @($scanInterfaces | Sort-Object @{Expression={ if ($_.InterfaceAlias -match 'Wi-Fi|WLAN|Wireless') {0} else {1} }} | ForEach-Object { $_.IPv4Address } | Where-Object {
    $_.IPAddress -match '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)'
})
if ($BindAddress) {
    $scanAddress = $scanCandidates | Where-Object { $_.IPAddress -eq $BindAddress } | Select-Object -First 1
} else {
    $scanAddress = $scanCandidates | Select-Object -First 1
}
if (-not $scanAddress) {
    if ($BindAddress) { throw 'The requested LAN address is not connected.' }
    $BindAddress = '127.0.0.1'
    $scanSubnet = '127.0.0.1/32'
    Write-Host 'No LAN connected. USB scanning is available without Wi-Fi.'
} else {
    $BindAddress = $scanAddress.IPAddress
    $scanSubnet = "$BindAddress/$($scanAddress.PrefixLength)"
}
Write-Host "Laptop Wi-Fi IPv4: $BindAddress"
Write-Host "Server address: https://${BindAddress}:$Port"
Write-Host 'Keep Windows Firewall enabled. If prompted, allow Python only on the Private network profile.'
Write-Host 'If a previous server is still listening on this port, stop that server with Ctrl+C first.'
Write-Host 'USB: enable USB debugging and accept the PC authorization. Debug app connects automatically.'
$env:PIP_CACHE_DIR = Join-Path $projectRoot '.scan-runtime\cache\pip'
$env:TEMP = Join-Path $projectRoot '.scan-runtime\tmp'
$env:TMP = $env:TEMP
New-Item -ItemType Directory -Force -Path $env:PIP_CACHE_DIR,$env:TEMP | Out-Null
if (-not (Test-Path -LiteralPath $scanPython)) {
    & py -3.11 -m venv (Join-Path $projectRoot '.scan-runtime')
    if ($LASTEXITCODE -ne 0) { throw 'Python 3.11 is required.' }
}
& $scanPython -m pip install --disable-pip-version-check numpy==1.26.4 opencv-python-headless==4.10.0.84 pycolmap==4.2.1 open3d==0.19.0 "cryptography>=44,<47" "qrcode>=8,<9" "zeroconf>=0.148,<1"
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
$env:SPATIAL_SEGMENT_PYTHON = $scanPython
& $env:SPATIAL_SEGMENT_PYTHON -B (Join-Path $PSScriptRoot 'setup_scan_segmentation.py')
if ($LASTEXITCODE -ne 0) { throw 'Object segmentation setup failed.' }
& $scanPython -B (Join-Path $PSScriptRoot 'setup_scan_mvs.py')
if ($LASTEXITCODE -ne 0) { throw 'Multi-view reconstruction setup failed.' }
& $scanPython -B -u (Join-Path $PSScriptRoot 'scan_server.py') --host $BindAddress --subnet $scanSubnet --port $Port --show-pairing
