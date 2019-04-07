# SCRIPT SQL_Recover.ps1

param(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [string] $source_database="servidor\SQLEXPRESS\master",      # Instancia de Base de Datos Origen a restaurar
    [string] $target_database_name="master_recover",             # Nombre con el que restaurar la Base de Datos
    [string] $target_server="servidor_destino",                             # Equipo Destino del Restore
    [string] $target_directory="C:\SQL\DATA"                     # Directorio a Restaurar   
)

function Write-Error($message) {
    [Console]::BackgroundColor = 'black'
    [Console]::ForegroundColor = 'red'
    [Console]::Error.WriteLine("[ERROR] " + $message)
    [Console]::ResetColor()
}


##############################################################
# LOGIN
Write-Host "`r`n[1] Obteniendo parametros para el restore"

try
{
    Get-UebApi -uri "/api/summary/current" | Out-Null
}
catch
{
    Write-Error "No es posible conectat con el Appliance Unitrends. Por favor, utilice Connect-UebServer para autenticarse o compruebe que el servidor esta disponible."
    exit 1
}

##############################################################
# BUSQUEDA DEL ULTIMO BACKUP

$source_database_iid = (Get-UebInventory -name $source_database).id
Write-Host "      source_database_iid=$source_database_iid"

try {
    $backups = (Get-UebApi -uri "/api/backups/latest/?sid=1&iid=$source_database_iid&days=7").data
} catch {
    Write-Error "No existen respaldos en el inventario del Appliance Unitrends para la Base de Datos $source_database $_"
    exit 1
}

$last_backup_id = ($backups | Sort-Object -Property start_time -Descending | Select-Object -First 1).backup_id
Write-Host "      last_backup_id=$last_backup_id"

##############################################################
# BUSQUEDA DE ID DEL EQUIPO DE DESTINO  

$target_client_id=(Get-UebInventory -name $target_server|Where-Object {$_.asset_type -eq "physical"}|Select-Object -First 1).id
Write-Host "      target_client_id=$target_client_id"

if ($target_client_id -eq $null) {
    Write-Error "No existe el Servidor $target_server en el inventario del Appliance Unitrends."
    exit 1
}

##############################################################
# BUSQUEDA DEL INSTANCE DE DESTINO  

$target_sql_instance_name = (get-uebapi -uri "/api/restore/targets/?app_type=SQL+Server&bid=$last_backup_id&iid=$source_database_iid&replicated=0&sid=1&targetID=$target_client_id").instances.instance_name | Select-Object -First 1
Write-Host "      target_sql_instance_name=$target_sql_instance_name"

if ($target_sql_instance_name -eq $null ) {
    Write-Error "No existe un instancia de SQL en el servidor $target_server compatible con el backup de $source_database " 
    exit 1
}

##############################################################
# RESTORE  

Write-Host "`r`n[2] Lanzando comando de restore:"
Write-Host "      Start-UebRestoreSql -backupID $last_backup_id -clientID $target_client_id -instance_name $target_sql_instance_name -database $target_database_name -directory $target_directory"
Write-Host ""
Start-UebRestoreSql -backupID $last_backup_id -clientID $target_client_id -instance_name $target_sql_instance_name -database $target_database_name -directory $target_directory