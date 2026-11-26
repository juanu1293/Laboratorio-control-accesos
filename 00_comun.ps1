# 00_comun.ps1 - variables y funciones compartidas (se carga con ". .\00_comun.ps1")
# NOTA: este archivo esta escrito en ASCII (sin tildes) para que PowerShell 5.1 no lo lea mal.

$LabRoot  = 'C:\LabControlAcceso'
$Datos    = Join-Path $LabRoot 'datos'
$Nomina   = Join-Path $Datos 'nomina.txt'
$Informe  = Join-Path $Datos 'informe.txt'
$Grupo    = 'LAB_Auditores'
$UsrAna   = 'lab_ana'     # usuaria autorizada (miembro de LAB_Auditores)
$UsrLuis  = 'lab_luis'    # usuario NO autorizado
$ClaveLab = 'Lab#2026Seguro!'   # clave SOLO para este laboratorio
$Evid     = Join-Path $PSScriptRoot 'evidencias'

function Test-Admin {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Exigir-Admin {
    if (-not (Test-Admin)) {
        Write-Host 'ERROR: abre VS Code con clic derecho > Ejecutar como administrador.' -ForegroundColor Red
        exit 1
    }
}

function Titulo {
    param([string]$Texto)
    Write-Host ''
    Write-Host ('=' * 64) -ForegroundColor Cyan
    Write-Host $Texto -ForegroundColor Cyan
    Write-Host ('=' * 64) -ForegroundColor Cyan
}

function Iniciar-Log {
    param([string]$Nombre)
    if (-not (Test-Path $Evid)) { New-Item -ItemType Directory -Path $Evid | Out-Null }
    Start-Transcript -Path (Join-Path $Evid $Nombre) -Force | Out-Null
}

# Ejecuta un comando de PowerShell COMO otro usuario y devuelve su salida como texto.
function Ejecutar-Como {
    param([string]$Usuario, [string]$Comando)
    $sec  = ConvertTo-SecureString $ClaveLab -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential("$env:COMPUTERNAME\$Usuario", $sec)
    $Comando = "`$ProgressPreference = 'SilentlyContinue'; " + $Comando
    $enc  = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Comando))
    $o = [IO.Path]::GetTempFileName()
    $e = [IO.Path]::GetTempFileName()
    try {
        Start-Process -FilePath 'powershell.exe' -Credential $cred `
            -WorkingDirectory "$env:SystemRoot\System32" `
            -ArgumentList @('-NoProfile', '-NonInteractive', '-OutputFormat', 'Text', '-EncodedCommand', $enc) `
            -RedirectStandardOutput $o -RedirectStandardError $e -Wait -WindowStyle Hidden
        # La salida del otro proceso viene en la codificacion OEM de la consola (evita tildes rotas)
        $oem = [Text.Encoding]::GetEncoding([Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage)
        $txt = [IO.File]::ReadAllText($o, $oem) + [IO.File]::ReadAllText($e, $oem)
        $txt = [regex]::Replace($txt, '(?s)#< CLIXML.*?</Objs>', '')
    } catch {
        $txt = 'ERROR al lanzar el proceso: ' + $_.Exception.Message
    } finally {
        Remove-Item $o, $e -Force -ErrorAction SilentlyContinue
    }
    return $txt
}

# Prueba si un usuario puede LEER o ESCRIBIR un archivo y lo muestra en verde/rojo.
function Probar-Acceso {
    param(
        [string]$Usuario,
        [string]$Ruta,
        [ValidateSet('Leer', 'Escribir')][string]$Accion = 'Leer'
    )
    $archivo = Split-Path $Ruta -Leaf
    if ($Accion -eq 'Leer') {
        $cmd = "try { `$t = Get-Content -LiteralPath '$Ruta' -ErrorAction Stop; 'PERMITIDO: ' + (`$t -join ' | ') } catch { 'DENEGADO: ' + `$_.Exception.Message }"
    } else {
        $cmd = "try { Add-Content -LiteralPath '$Ruta' -Value 'linea agregada por $Usuario' -ErrorAction Stop; 'PERMITIDO: escritura realizada' } catch { 'DENEGADO: ' + `$_.Exception.Message }"
    }
    $res = (Ejecutar-Como -Usuario $Usuario -Comando $cmd).Trim()
    $color = 'Red'
    if ($res -like 'PERMITIDO*') { $color = 'Green' }
    Write-Host ('[{0}] {1} {2} -> {3}' -f $Usuario, $Accion, $archivo, $res) -ForegroundColor $color
}