# Compila el APK release de MacrosApp con la última versión del código.
# Uso: abre PowerShell en la carpeta del proyecto y ejecuta:
#   .\build_apk.ps1
# (o desde cualquier sitio: powershell -File "C:\Users\Alex Sivera\Desktop\Proyectos\Apps\MacrosApp\build_apk.ps1")
#
# El APK release ocupa mucho menos que el de depuración y va más fluido.
# Se firma con la clave de depuración de este PC, así que se instala encima
# de versiones anteriores sin perder los datos.

$ErrorActionPreference = "Stop"
$projectDir = $PSScriptRoot
Set-Location $projectDir

# Java/Gradle fallan con "Unable to establish loopback connection" cuando la
# carpeta temporal está bajo un usuario con espacio (C:\Users\ALEXSI~1\...).
# Usamos una carpeta temporal corta solo para este proceso.
$shortTemp = "C:\gtmp"
New-Item -ItemType Directory -Force $shortTemp | Out-Null
$env:TEMP = $shortTemp
$env:TMP = $shortTemp
$env:JAVA_TOOL_OPTIONS = "-Djdk.net.unixdomain.tmpdir=$shortTemp -Djava.io.tmpdir=$shortTemp"

# Un daemon de Gradle arrancado con la carpeta temporal antigua seguiría fallando.
Push-Location (Join-Path $projectDir "android")
& .\gradlew.bat --stop | Out-Null
Pop-Location

Write-Host "Compilando MacrosApp (release)..." -ForegroundColor Cyan
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    $apkPath = Join-Path $projectDir "build\app\outputs\flutter-apk\app-release.apk"
    $sizeMb = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)
    Write-Host ""
    Write-Host "Listo. APK ($sizeMb MB) en: $apkPath" -ForegroundColor Green
    Write-Host "Para pasarla al movil por WhatsApp, enviala como Documento." -ForegroundColor Gray

    # Si hay un dispositivo Android conectado por USB, ofrece instalarlo directamente.
    $devices = flutter devices --machine 2>$null | ConvertFrom-Json
    $androidDevice = $devices | Where-Object { $_.targetPlatform -like "android-*" } | Select-Object -First 1
    if ($androidDevice) {
        Write-Host ""
        $answer = Read-Host "Dispositivo Android detectado ($($androidDevice.name)). ¿Instalar ahora? (s/n)"
        if ($answer -eq "s") {
            flutter install --release
        }
    }
} else {
    Write-Host ""
    Write-Host "La compilacion fallo. Revisa el error de arriba." -ForegroundColor Red
    Write-Host "Si ves errores raros de SDK/paquetes no encontrados, prueba:" -ForegroundColor Yellow
    Write-Host "  flutter clean; flutter pub get" -ForegroundColor Yellow
}
