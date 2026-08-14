# Compila el APK de depuración de MacrosApp con la última versión del código.
# Uso: abre PowerShell en la carpeta del proyecto y ejecuta:
#   .\build_apk.ps1
# (o desde cualquier sitio: powershell -File "C:\Users\Alex Sivera\Desktop\MacrosApp\build_apk.ps1")

$ErrorActionPreference = "Stop"
Set-Location "C:\Users\Alex Sivera\Desktop\MacrosApp"

Write-Host "Compilando MacrosApp..." -ForegroundColor Cyan
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    $apkPath = "C:\Users\Alex Sivera\Desktop\MacrosApp\build\app\outputs\flutter-apk\app-debug.apk"
    Write-Host ""
    Write-Host "Listo. APK en: $apkPath" -ForegroundColor Green

    # Si hay un dispositivo Android conectado por USB, ofrece instalarlo directamente.
    $devices = flutter devices --machine 2>$null | ConvertFrom-Json
    $androidDevice = $devices | Where-Object { $_.targetPlatform -like "android-*" }
    if ($androidDevice) {
        Write-Host ""
        $answer = Read-Host "Dispositivo Android detectado ($($androidDevice.name)). ¿Instalar ahora? (s/n)"
        if ($answer -eq "s") {
            flutter install
        }
    }
} else {
    Write-Host ""
    Write-Host "La compilacion fallo. Revisa el error de arriba." -ForegroundColor Red
    Write-Host "Si ves errores raros de SDK/paquetes no encontrados, prueba:" -ForegroundColor Yellow
    Write-Host "  flutter clean; flutter pub get" -ForegroundColor Yellow
}
