$ErrorActionPreference = 'Stop'
$backendRoot = Split-Path $PSScriptRoot -Parent
$runtime = Join-Path $backendRoot '.triposr-runtime'
$python = Join-Path $runtime 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $python)) {
    & py -3.11 -m venv $runtime
    if ($LASTEXITCODE -ne 0) { throw 'Install Python 3.11 first.' }
}
& $python -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { throw 'pip setup failed.' }
& $python -m pip install torch==2.6.0+cpu torchvision==0.21.0+cpu --index-url https://download.pytorch.org/whl/cpu
if ($LASTEXITCODE -ne 0) { throw 'PyTorch CPU setup failed.' }
& $python -m pip install -e "$PSScriptRoot[test]" 'cmake>=4.2' 'scikit-build-core>=1.0' 'pybind11>=2.13' ninja
if ($LASTEXITCODE -ne 0) { throw 'Python dependencies setup failed.' }
& $python -m nhombar_photo3d.prepare
if ($LASTEXITCODE -ne 0) { throw 'Official model download failed.' }
$env:CMAKE_PREFIX_PATH = (& $python -c 'import torch; print(torch.utils.cmake_prefix_path)').Trim()
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path -LiteralPath $vswhere) {
    $visualStudio = & $vswhere -latest -prerelease -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $visualStudio) {
        $devCandidate = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft Visual Studio\*\*\Common7\Tools\VsDevCmd.bat') -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($devCandidate) { $visualStudio = Split-Path (Split-Path (Split-Path $devCandidate.FullName -Parent) -Parent) -Parent }
    }
    if ($visualStudio) {
        $devCommand = Join-Path $visualStudio 'Common7\Tools\VsDevCmd.bat'
        $buildEnvironment = & $env:ComSpec /d /c "call `"$devCommand`" -no_logo -arch=x64 -host_arch=x64 >nul && set"
        foreach ($line in $buildEnvironment) {
            if ($line -match '^(PATH|INCLUDE|LIB|LIBPATH|VCINSTALLDIR|VSINSTALLDIR|VCTools\w+|WindowsSdk\w*|UCRT\w*|UniversalCRTSdkDir)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
            }
        }
    }
}
$env:PATH = (Join-Path $runtime 'Scripts') + ';' + $env:PATH
$env:CMAKE_GENERATOR = 'Ninja'
& $python -m pip install --no-build-isolation --config-settings=build-dir=build-cpu (Join-Path $runtime 'torchmcubes')
if ($LASTEXITCODE -ne 0) { throw 'torchmcubes needs Visual Studio C++ Build Tools and the Windows SDK.' }
Write-Host 'Ready. Run backend/.triposr-runtime/Scripts/python.exe -m nhombar_photo3d'
