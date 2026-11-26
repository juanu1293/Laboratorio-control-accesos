# 01_setup.ps1 - crea usuarios, grupo y archivos confidenciales de prueba
. "$PSScriptRoot\00_comun.ps1"
Exigir-Admin
Titulo 'PASO 1: preparar el entorno del laboratorio'

$sec = ConvertTo-SecureString $ClaveLab -AsPlainText -Force

foreach ($u in @($UsrAna, $UsrLuis)) {
    if (-not (Get-LocalUser -Name $u -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name $u -Password $sec -PasswordNeverExpires -UserMayNotChangePassword `
            -Description 'Usuario estandar de laboratorio' | Out-Null
        Write-Host "Usuario creado: $u" -ForegroundColor Green
    } else {
        Write-Host "Usuario ya existia: $u"
    }
}

if (-not (Get-LocalGroup -Name $Grupo -ErrorAction SilentlyContinue)) {
    New-LocalGroup -Name $Grupo -Description 'Autorizados a leer datos confidenciales' | Out-Null
    Write-Host "Grupo creado: $Grupo" -ForegroundColor Green
}
try { Add-LocalGroupMember -Group $Grupo -Member $UsrAna -ErrorAction Stop } catch { }

New-Item -ItemType Directory -Path $Datos -Force | Out-Null
Set-Content -Path $Nomina  -Value 'CONFIDENCIAL: nomina de empleados - salarios y cuentas bancarias'
Set-Content -Path $Informe -Value 'Informe trimestral - uso interno'

Write-Host ''
Write-Host "Carpeta de datos: $Datos" -ForegroundColor Yellow
Write-Host "Miembros de ${Grupo}:" -ForegroundColor Yellow
Get-LocalGroupMember -Group $Grupo | Format-Table Name, ObjectClass -AutoSize | Out-String | Write-Host
Write-Host 'Listo. Ahora ejecuta 02_sin_control.ps1' -ForegroundColor Green
