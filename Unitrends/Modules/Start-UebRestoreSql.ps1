<#
.Synopsis
   Submits a SQL Restore Job
.DESCRIPTION
    Start-UebRestoreSql -backupID 11148 -clientID 35 -instance_name WIR02\SQLRDR -database ReliableDR
.PARAMETER SID
    System ID of the Unitrends Appliance.
.PARAMETER BackupID
    Backup ID to be restored   
.PARAMETER ClientID
    ID of the Client Machine
.PARAMETER Directory
    Location on the server to re-direct this restore to. If blank, restore will go to where it was backed up from.
.EXAMPLE
    Start-UebRestoreSql -backupID 11148 -clientID 35 -instance_name WIR02\SQLRDR -database ReliableDR
#>
function Start-UebRestoreSql{
param(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [int]$sid = 1,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [int]$backupID,
    [int]$clientID,
    [string]$instance_name,
    [string]$database,
    [string]$directory
)
# Verb Options?   Start- Submit-




#region RestoreObject
# Build the Restore Object, make $target, $theseIncludes, $theseExcludes, then make $body out of all and more
# Build Target
$target = @{
    instance = $instance_name
    database = $database
    directory = $directory
}

#Build Body
$body = @{
    backup_id = $backupID
    client_id = $clientID
    target = $target
}
#endregion RestoreObject


UebPost "/api/restore/full/?sid=$sid" $body







}
