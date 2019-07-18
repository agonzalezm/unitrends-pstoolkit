# SCRIPT SQL_Recover.ps1

param(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [int] $source_database_iid=2052,
    [string] $source_database="DC1PVDBUC3\PRDBUC2\AXA_RS",      # Instancia de Base de Datos Origen a restaurar
    [string] $target_database_name="AXA_RS",             # Nombre con el que restaurar la Base de Datos
    [string] $target_server="DC2TVDSQL16",                             # Equipo Destino del Restore
    [string] $target_directory="E:\Data\Restore",                     # Directorio a Restaurar   
    [string] $target_directory_log="F:\Log",				# Directori donde mover los logs
    [string] $target_sql_instance_name=$null,           # sql instance name or null for get the first one
    # UEB LOGIN
    [string] $Server="192.168.1.130",
    [string] $User="root",
    [string] $Password="pass"
)

function Write-Error($message) {
    [Console]::BackgroundColor = 'black'
    [Console]::ForegroundColor = 'red'
    [Console]::Error.WriteLine("[ERROR] " + $message)
    [Console]::ResetColor()
}


##############################################################
# LOGIN
Write-Host "`r`n[1] Autenticando con el appliance"

try
{
    Connect-UebServer -Server $Server -User $User -Password $Password | Out-Null
    Get-UebApi -uri "/api/summary/current" | Out-Null
}
catch
{
    Write-Error "No es posible conectat con el Appliance Unitrends. Por favor, utilice Connect-UebServer para autenticarse o compruebe que el servidor esta disponible."
    exit 1
}

##############################################################
# BUSQUEDA DEL ULTIMO BACKUP

#$source_database_iid = (Get-UebInventory -name $source_database).id
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

if ($target_sql_instance_name -eq $null ) {
    $target_sql_instance_name = (get-uebapi -uri "/api/restore/targets/?app_type=SQL+Server&bid=$last_backup_id&iid=$source_database_iid&replicated=0&sid=1&targetID=$target_client_id").instances.instance_name | Select-Object -First 1
    Write-Host "      target_sql_instance_name=$target_sql_instance_name"

    if ($target_sql_instance_name -eq $null ) {
        Write-Error "No existe un instancia de SQL en el servidor $target_server compatible con el backup de $source_database " 
        exit 1
    }
} else {
    Write-Host "      target_sql_instance_name=$target_sql_instance_name"
}

##############################################################
# RESTORE  

Write-Host "`r`n[2] Lanzando comando de restore:"
Write-Host "      Start-UebRestoreSql -backupID $last_backup_id -clientID $target_client_id -instance_name $target_sql_instance_name -database $target_database_name -directory $target_directory"
Write-Host ""
$restore = Start-UebRestoreSql -backupID $last_backup_id -clientID $target_client_id -instance_name $target_sql_instance_name -database $target_database_name -directory $target_directory
$restore_id = $restore.id

Write-Host "`r`n[3] Esperando que termine el restore ($restore_id):"

$restore_job = $null
while($restore_job -eq $null) {
    $restore_job = get-uebjob -Active|Where-Object {$_.id -eq $restore_id}
    Sleep 3
}

while($restore_job.status -eq "Queued" -or $restore_job.status -eq "Active" -or $restore_job.status -eq "Connecting")
{
    $restore_job = get-uebjob -Active|Where-Object {$_.id -eq $restore_id}
    Sleep 3
}


Write-Host "`r`n[3] Obteniendo fichero de log:"

$log_name = $source_database.split('\')[-1] + "_log"
$log_file=Get-ChildItem -Path $target_directory -Recurse -Include *.ldf
if($log_file.count -gt 1)
{
    Write-Error "   Se han encontrado mas de 1 log, no esta soportado mover mas de 1 logfile"
}
$log_filename=$log_file.Name

Write-Host "`r`n[4] Modificando database log:"
Write-Host "`r`n      sqlcmd -S $target_sql_instance_name -Q 'ALTER DATABASE [$target_database_name] MODIFY FILE (name='$log_name',filename='$target_directory_log\$log_filename'); ALTER DATABASE [$target_database_name] SET OFFLINE WITH ROLLBACK IMMEDIATE;'"
sqlcmd -S $target_sql_instance_name -Q "ALTER DATABASE [$target_database_name] MODIFY FILE (name='$log_name',filename='$target_directory_log\$log_filename');"
sqlcmd -S $target_sql_instance_name -Q "ALTER DATABASE [$target_database_name] SET OFFLINE;"

Write-Host "`r`n      Move-Item -Path $logfile -Destination $target_directory_log"
if(Test-Path -Path $target_directory_log\$log_filename )
{
    Remove-Item -Path $target_directory_log\$log_filename 
}

Move-Item -Path $log_file -Destination $target_directory_log

Write-Host "`r`n[5] Reiniciando database:"
Write-Host "`r`n      sqlcmd -S $target_sql_instance_name -Q  'ALTER DATABASE [$target_database_name] SET ONLINE;'"
sqlcmd -S $target_sql_instance_name -Q  "ALTER DATABASE [$target_database_name] SET ONLINE;" 
Write-Host "`r`n[6] Finalizado correctamente."