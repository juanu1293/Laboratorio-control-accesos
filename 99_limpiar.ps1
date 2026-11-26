# 99_limpiar.ps1 - elimina todo lo creado por el laboratorio
. "$PSScriptRoot\00_comun.ps1"
Exigir-Admin
Titulo 'LIMPIEZA del laboratorio'

foreach ($u in @($UsrAna, $UsrLuis, 'lab_prueba_x')) {
    if (Get-LocalUser -Name $u -ErrorAction SilentlyContinue) {
        Remove-LocalUser -Name $u
        Write-Host "Usuario eliminado: $u"
    }
    $perfil = "C:\Users\$u"
    if (Test-Path $perfil) { Remove-Item $perfil -Recurse -Force -ErrorAction SilentlyContinue }
}
if (Get-LocalGroup -Name $Grupo -ErrorAction SilentlyContinue) {
    Remove-LocalGroup -Name $Grupo
    Write-Host "Grupo eliminado: $Grupo"
}
if (Test-Path $LabRoot) {
    Remove-Item $LabRoot -Recurse -Force
    Write-Host "Carpeta eliminada: $LabRoot"
}
Write-Host 'Limpieza terminada (la carpeta evidencias del proyecto no se toca).' -ForegroundColor Green
