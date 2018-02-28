param(
)

# User Defined Settings
$ESXHost = "38373035-3436-5a43-4a39-343430343745"
$Datastore = "TINTRI"
$UebIp = "192.168.11.20"
$VMs = @("SQL01","TCL.ddiez.100")
$VMextension = "_restore"
#

foreach($vm in $VMs)
{
    $Name = $($vm + $VMextension)
    Write-Host "Recovering VM $vm as $Name"
    $lastbackup = Get-UebBackup -VM $vm | Sort-Object -Property start_date -Descending | Select-Object -First 1
    Start-UebIr -Host $ESXHost -Name $Name -Datastore $Datastore -BackupId $lastbackup.id -Address $UebIp
}

Write-Host "Recovered VM Status:"
Get-UebIr

        
      