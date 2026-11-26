# Laboratorio: Control de acceso (permisos + ACL) y mínimo privilegio en Windows 10

Demuestra cómo los permisos NTFS y las ACL (con el principio de mínimo privilegio) reducen el riesgo de **acceso no autorizado a información confidencial**.

## Requisitos
- Windows 10 y VS Code (sin instalar nada más).
- VS Code abierto **como administrador** (clic derecho > *Ejecutar como administrador*).
- Terminal integrada en **PowerShell**.

## Ejecución
En la terminal de VS Code, dentro de la carpeta del proyecto:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass   # solo vale para esta terminal
.\01_setup.ps1              # crea usuarios, grupo y archivos
.\02_sin_control.ps1        # RIESGO: luis lee y modifica la nómina
.\03_permisos.ps1           # MECANISMO: quita herencia y asigna permisos al grupo
.\04_acl.ps1                # ACL de grano fino sobre informe.txt
.\05_minimo_privilegio.ps1  # usuario estándar vs. administrador (opcional: -DemoUAC)
.\99_limpiar.ps1            # borra todo al terminar
```

Cada script guarda su log en `evidencias\`. Toma además capturas de pantalla de la terminal.

## Qué se crea
| Elemento | Detalle |
|---|---|
| Usuarios | `lab_ana` (autorizada), `lab_luis` (no autorizado). Clave de laboratorio en `00_comun.ps1` |
| Grupo | `LAB_Auditores` (contiene a `lab_ana`) |
| Datos | `C:\LabControlAcceso\datos\nomina.txt` e `informe.txt` |

## Resultados esperados
| Prueba | Antes (paso 2) | Después |
|---|---|---|
| luis lee nomina.txt | PERMITIDO (riesgo) | DENEGADO |
| luis escribe nomina.txt | PERMITIDO (riesgo) | DENEGADO |
| ana lee nomina.txt | — | PERMITIDO (por el grupo) |
| ana escribe nomina.txt | — | DENEGADO (solo lectura) |
| luis lee / escribe informe.txt | — | PERMITIDO / DENEGADO (paso 4) |
| luis crea un usuario | — | DENEGADO (no es administrador) |

## Problemas frecuentes
- *"la ejecución de scripts está deshabilitada"*: ejecuta la línea `Set-ExecutionPolicy -Scope Process ...` de arriba.
- *Error al lanzar el proceso como otro usuario*: inicia el servicio "Inicio de sesión secundario" (`Start-Service seclogon`).
- Si cambias la clave de `$ClaveLab`, debe cumplir la política de contraseñas de Windows.
