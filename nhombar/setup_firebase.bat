@echo off
setlocal
cd /d "%~dp0"
:: =====================================================================
:: setup_firebase.bat — Cấu hình Firebase cho ứng dụng Nhóm Bar
:: Chạy file này bằng cách double-click hoặc từ Command Prompt
:: =====================================================================

echo.
echo ========================================
echo   NHOM BAR — FIREBASE SETUP SCRIPT
echo ========================================
echo.
echo Tat ca cac buoc duoi day phai duoc thuc hien theo thu tu.
echo.

:: --- BUOC 1: Kiem tra Firebase CLI ---
echo [1/5] Kiem tra Firebase CLI...
call firebase --version
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
call firebase login
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
echo   - Dung Firebase project nhom-bar da co, khong tao project khac
echo   - Chon nen tang: Android (bat buoc), iOS (tuy chon)
echo   - Xac nhan tao file firebase_options.dart va google-services.json
echo.
call "%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat" configure --project=nhom-bar --platforms=android
IF %ERRORLEVEL% NEQ 0 (
    echo THAT BAI: flutterfire configure gap loi.
    echo Kiem tra quyen truy cap project nhom-bar, khong doi sang project khac.
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
echo 2. Vao project "nhom-bar" ^> Build ^> Realtime Database
echo 3. Bat Email/Password va Google trong Authentication.
echo 4. Kiem tra Firestore/Storage Rules theo UID; khong mo quyen test toan bo.
echo 5. Bartender/Rubik online van dung API Node.js trong backend.
echo.
echo Huong dan day du: ..\README.md
pause
