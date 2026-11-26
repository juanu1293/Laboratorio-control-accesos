# 02_sin_control.ps1 - demuestra el RIESGO: sin control de acceso, cualquiera accede
. "$PSScriptRoot\00_comun.ps1"
Exigir-Admin
Iniciar-Log '02_sin_control_log.txt'
Titulo 'PASO 2: SIN control de acceso (estado inicial = riesgo)'

Write-Host 'ACL actual de la carpeta de datos:' -ForegroundColor Yellow
icacls $Datos | Out-String | Write-Host
Write-Host 'Fijate en "Authenticated Users" / "Usuarios autenticados" con permiso (M) = modificar.' -ForegroundColor Yellow
Write-Host ''

Write-Host 'Pruebas con lab_luis (usuario SIN autorizacion):' -ForegroundColor Yellow
Probar-Acceso -Usuario $UsrLuis -Ruta $Nomina -Accion Leer
Probar-Acceso -Usuario $UsrLuis -Ruta $Nomina -Accion Escribir

Write-Host ''
Write-Host 'RIESGO: un usuario no autorizado leyo y modifico informacion confidencial.' -ForegroundColor Red
Write-Host '(Se viola confidencialidad e integridad.)' -ForegroundColor Red
Stop-Transcript | Out-Null
