# GYM STAR - Deploy to Phone
# Run this script after connecting your phone via USB with USB Debugging enabled

$ADB = "C:\Users\raman\Android\Sdk\platform-tools\adb.exe"
$APK = "flutter_app\build\app\outputs\flutter-apk\app-debug.apk"
$DEVICE = "77322a8a"

Write-Host "Checking device..." -ForegroundColor Cyan
& $ADB devices

Write-Host "Reversing port 8000..." -ForegroundColor Cyan
& $ADB -s $DEVICE reverse tcp:8000 tcp:8000

Write-Host "Installing APK..." -ForegroundColor Yellow
& $ADB -s $DEVICE install -r $APK

Write-Host "Launching GYM STAR..." -ForegroundColor Green
& $ADB -s $DEVICE shell am start -n com.example.gymstar_mobile/.MainActivity

Write-Host "Done! Check your phone." -ForegroundColor Green
