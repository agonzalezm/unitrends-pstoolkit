##Example on how to pull data points for the last 10 backups on a system.

$uebURL = 'recovery01'
$uebUSER = 'root'
$uebPASS = 'xxxxxxx'
$historypoints = '10'

Import-Module Unitrends
Connect-UebServer -Server $ueburl -User $uebUSER -Password $uebPASS

$results = ((Get-UebJob -Recent).backups | ?{$_.client_name -eq 'SERVERNAME'} | Sort-Object start_time -Descending | Select-Object -first $historypoints)

ForEach($result in $results)
{
    $Query = "INSERT INTO CUSTOM_TABLE ('BackupID','InstanceID','Start Time','Asset Name','Mode','Status','Message') VALUES ('$($result.id)','$($result.instance_id)','$($result.asset_name)','$($result.mode)','$($result.status)','$($result.message)');"
    
    Write-Output $Query
}
