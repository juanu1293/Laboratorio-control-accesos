# 03_permisos.ps1 - aplica el mecanismo: quitar herencia + conceder acceso solo al grupo autorizado
. "$PSScriptRoot\00_comun.ps1"
Exigir-Admin
Iniciar-Log '03_permisos_log.txt'
Titulo 'PASO 3: aplicar permisos (principio de minimo privilegio)'

# Se usan SID conocidos para que funcione en Windows en espanol o ingles:
#   *S-1-5-32-544 = Administradores   *S-1-5-18 = SYSTEM
Write-Host '1) Quitar la herencia (se eliminan permisos heredados de C:\)' -ForegroundColor Yellow
icacls $Datos /inheritance:r | Out-Null

Write-Host '2) Conceder acceso solo a quien lo necesita' -ForegroundColor Yellow
icacls $Datos /grant:r '*S-1-5-32-544:(OI)(CI)F' '*S-1-5-18:(OI)(CI)F' "${Grupo}:(OI)(CI)R" | Out-Null

Write-Host ''
Write-Host 'Nueva ACL:' -ForegroundColor Yellow
icacls $Datos | Out-String | Write-Host

Write-Host 'Pruebas despues de aplicar el mecanismo:' -ForegroundColor Yellow
Probar-Acceso -Usuario $UsrLuis -Ruta $Nomina -Accion Leer      # debe fallar
Probar-Acceso -Usuario $UsrLuis -Ruta $Nomina -Accion Escribir  # debe fallar
Probar-Acceso -Usuario $UsrAna  -Ruta $Nomina -Accion Leer      # debe funcionar (grupo)
Probar-Acceso -Usuario $UsrAna  -Ruta $Nomina -Accion Escribir  # debe fallar (solo lectura)

Write-Host ''
Write-Host 'Resultado: solo el grupo autorizado lee, y nadie mas de forma indebida.' -ForegroundColor Green
Stop-Transcript | Out-Null
