# GYM STAR Flutter Launcher Script
$env:Path += ";C:\Users\raman\flutter\bin"

Write-Host "Flutter PATH configured." -ForegroundColor Green

Set-Location "c:\Users\raman\OneDrive\Desktop\projects\gymstar\flutter_app"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   GYM STAR Mobile App - Flutter Launcher" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available targets:" -ForegroundColor Yellow
Write-Host "  [1] Chrome (Web Browser)"
Write-Host "  [2] Windows Desktop"
Write-Host "  [3] Connected Android Device (USB / Mobile)"
Write-Host ""

$choice = Read-Host "Pick a target (1, 2, or 3)"

if ($choice -eq "1") {
    Write-Host "Launching on Chrome..." -ForegroundColor Green
    & "C:\Users\raman\flutter\bin\flutter.bat" run -d chrome
} elseif ($choice -eq "2") {
    Write-Host "Launching on Windows Desktop..." -ForegroundColor Green
    & "C:\Users\raman\flutter\bin\flutter.bat" run -d windows
} elseif ($choice -eq "3") {
    Write-Host "Forwarding backend port 8000 to phone..." -ForegroundColor Cyan
    & "C:\Users\raman\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
    Write-Host "Launching on Connected Android Device..." -ForegroundColor Green
    & "C:\Users\raman\flutter\bin\flutter.bat" run -d android
} else {
    Write-Host "Defaulting to Chrome..." -ForegroundColor Yellow
    & "C:\Users\raman\flutter\bin\flutter.bat" run -d chrome
}
