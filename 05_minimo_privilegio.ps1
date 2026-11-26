# 05_minimo_privilegio.ps1 - usuario estandar vs. elevacion puntual (equivalente a sudo)
# Uso normal:      .\05_minimo_privilegio.ps1
# Con ventana UAC: .\05_minimo_privilegio.ps1 -DemoUAC
param([switch]$DemoUAC)
. "$PSScriptRoot\00_comun.ps1"
Exigir-Admin
Iniciar-Log '05_minimo_privilegio_log.txt'
Titulo 'PASO 5: minimo privilegio - usuario estandar vs administrador'

Write-Host 'A) lab_luis (usuario estandar) intenta tareas de administrador:' -ForegroundColor Yellow
$crear = Ejecutar-Como -Usuario $UsrLuis -Comando "try { New-LocalUser -Name lab_prueba_x -NoPassword -ErrorAction Stop | Out-Null; 'PERMITIDO: usuario creado' } catch { 'DENEGADO: ' + `$_.Exception.Message }"
Write-Host ('   Crear un usuario    -> ' + $crear.Trim()) -ForegroundColor Red
$sys = Ejecutar-Como -Usuario $UsrLuis -Comando "try { Set-Content -Path 'C:\Windows\System32\lab_prueba.txt' -Value x -ErrorAction Stop; 'PERMITIDO' } catch { 'DENEGADO: ' + `$_.Exception.Message }"
Write-Host ('   Escribir en System32 -> ' + $sys.Trim()) -ForegroundColor Red

Write-Host ''
Write-Host 'B) Nivel de integridad y privilegios del token:' -ForegroundColor Yellow
$privLuis  = Ejecutar-Como -Usuario $UsrLuis -Comando 'whoami /priv'
$privAdmin = whoami /priv | Out-String
$nLuis  = ([regex]::Matches($privLuis,  'Se\w+Privilege')).Count
$nAdmin = ([regex]::Matches($privAdmin, 'Se\w+Privilege')).Count
Write-Host ('   lab_luis (usuario estandar)  : {0} privilegios' -f $nLuis)  -ForegroundColor Green
Write-Host ('   Administrador (sesion elevada): {0} privilegios' -f $nAdmin) -ForegroundColor Red
Write-Host ''
Write-Host '   Privilegios sensibles (SI = el token los tiene):' -ForegroundColor Yellow
foreach ($pv in @('SeDebugPrivilege', 'SeLoadDriverPrivilege', 'SeTakeOwnershipPrivilege', 'SeBackupPrivilege', 'SeRestorePrivilege', 'SeSecurityPrivilege')) {
    $l = 'NO'; if ($privLuis  -match $pv) { $l = 'SI' }
    $a = 'NO'; if ($privAdmin -match $pv) { $a = 'SI' }
    Write-Host ('     {0,-26} luis: {1}   admin: {2}' -f $pv, $l, $a)
}

Write-Host ''
Write-Host 'C) La MISMA tarea con elevacion puntual (solo cuando hace falta):' -ForegroundColor Yellow
net user lab_prueba_x 'Clave#12345' /add 2>&1 | Out-String | Write-Host
net user lab_prueba_x /delete 2>&1 | Out-String | Write-Host

if ($DemoUAC) {
    Write-Host 'Abriendo ventana elevada (aparecera el aviso de UAC si tu sesion no es elevada)...' -ForegroundColor Cyan
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile', '-NoExit', '-Command', 'whoami /groups'
}

Write-Host ''
Write-Host 'Conclusion: el trabajo diario se hace como usuario estandar; los privilegios' -ForegroundColor Green
Write-Host 'de administrador se usan solo de forma puntual (UAC / RunAs = "sudo" de Windows).' -ForegroundColor Green
Stop-Transcript | Out-Null