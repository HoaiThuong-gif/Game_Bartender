@echo off
:: =====================================================================
:: setup_firebase.bat — Hướng dẫn từng bước cài Firebase cho Bartender
:: Chạy file này bằng cách double-click hoặc từ Command Prompt
:: =====================================================================

echo.
echo ========================================
echo   BARTENDER — FIREBASE SETUP SCRIPT
echo ========================================
echo.
echo Tat ca cac buoc duoi day phai duoc thuc hien theo thu tu.
echo.

:: --- BUOC 1: Kiem tra Firebase CLI ---
echo [1/5] Kiem tra Firebase CLI...
firebase --version
IF %ERRORLEVEL% NEQ 0 (
    echo THAT BAI: Firebase CLI chua duoc cai. Chay: npm install -g firebase-tools
    pause
    exit /b 1
)
echo OK.
echo.

:: --- BUOC 2: Dang nhap Firebase ---
echo [2/5] Dang nhap Firebase (se mo trinh duyet)...
echo Dang nhap bang Google account cua nhom.
firebase login
IF %ERRORLEVEL% NEQ 0 (
    echo THAT BAI: Dang nhap that bai.
    pause
    exit /b 1
)
echo OK.
echo.

:: --- BUOC 3: Kiem tra FlutterFire CLI ---
echo [3/5] Kiem tra FlutterFire CLI...
call "%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat" --version
IF %ERRORLEVEL% NEQ 0 (
    echo THAT BAI: FlutterFire CLI chua duoc cai. Chay: dart pub global activate flutterfire_cli
    pause
    exit /b 1
)
echo OK.
echo.

:: --- BUOC 4: Chay flutterfire configure ---
echo [4/5] Chay flutterfire configure...
echo.
echo Khi duoc hoi:
echo   - Chon hoac tao Firebase project (ten goi y: nhom-bar-game)
echo   - Chon nen tang: Android (bat buoc), iOS (tuy chon)
echo   - Xac nhan tao file firebase_options.dart va google-services.json
echo.
call "%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat" configure --project=nhom-bar-game --platforms=android
IF %ERRORLEVEL% NEQ 0 (
    echo THAT BAI: flutterfire configure gap loi.
    echo Thu lai khong co --project flag: flutterfire configure
    pause
    exit /b 1
)
echo OK.
echo.

:: --- BUOC 5: Kiem tra ket qua ---
echo [5/5] Kiem tra ket qua...
IF EXIST "lib\firebase_options.dart" (
    echo [OK] lib\firebase_options.dart da duoc tao.
) ELSE (
    echo [LOI] Khong tim thay firebase_options.dart!
)

IF EXIST "android\app\google-services.json" (
    echo [OK] android\app\google-services.json da duoc tao.
) ELSE (
    echo [LOI] Khong tim thay google-services.json!
)

echo.
echo ========================================
echo   HOAN THANH! Tiep theo:
echo ========================================
echo.
echo 1. Mo Firebase Console: https://console.firebase.google.com
echo 2. Vao project "nhom-bar-game" ^> Build ^> Realtime Database
echo 3. Bam "Create Database" ^> chon "Start in test mode"
echo 4. Copy database URL (dang: nhom-bar-game-default-rtdb.firebaseio.com)
echo 5. Bao lai coding agent: "Firebase setup xong, database URL la: ..."
echo.
echo Sau do:
echo 6. Doi BartenderConfig.useFakeRepository = false de dung Firebase that
echo.
pause
