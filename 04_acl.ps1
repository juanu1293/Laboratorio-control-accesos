# 04_acl.ps1 - ACL de grano fino: permisos distintos por archivo y por usuario
. "$PSScriptRoot\00_comun.ps1"
Exigir-Admin
Iniciar-Log '04_acl_log.txt'
Titulo 'PASO 4: ACL de grano fino sobre informe.txt'

Write-Host 'luis: solo lectura | ana: modificar (ambos solo sobre informe.txt)' -ForegroundColor Yellow
icacls $Informe /grant "${UsrLuis}:R" | Out-Null
icacls $Informe /grant "${UsrAna}:M" | Out-Null

Write-Host ''
Write-Host 'ACL de informe.txt:' -ForegroundColor Yellow
icacls $Informe | Out-String | Write-Host

Write-Host 'Pruebas:' -ForegroundColor Yellow
Probar-Acceso -Usuario $UsrLuis -Ruta $Informe -Accion Leer      # debe funcionar
Probar-Acceso -Usuario $UsrLuis -Ruta $Informe -Accion Escribir  # debe fallar
Probar-Acceso -Usuario $UsrLuis -Ruta $Nomina   -Accion Leer     # debe fallar (sigue protegida)
Probar-Acceso -Usuario $UsrAna  -Ruta $Informe -Accion Escribir  # debe funcionar

Write-Host ''
Write-Host 'Una ACL permite decidir QUIEN puede hacer QUE sobre CADA objeto.' -ForegroundColor Green
Stop-Transcript | Out-Null
