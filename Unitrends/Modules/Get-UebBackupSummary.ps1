function Get-UebBackupSummary1 {
	[CmdletBinding()]
	param(
        [string]$rpo = 24
	)

	CheckConnection
	
	$response = UebGet("api/catalog")
	$instances = $response.catalog.instances
	
	[array]$vmlist = $null
	$date = Get-Date
    $rpo = New-TimeSpan -Hours $rpo

	foreach($i in $instances){
		$lastbackup = $i.backups | Sort-Object -Property start_date -Descending | Select-Object -First 1
		$backup_date = [datetime] $lastbackup.start_date
		$rpa = New-TimeSpan -Start $backup_date -End $date	
        $thisName = $i.database_name
        if ($i.app_type -eq "Physical Server"){
            $thisname =  $i.client_name
        }
        # Need a if statement to alter the "VM" name if this is a physical machine


        if($rpa -le $rpo) {
            $rpo_compliance = "OK"
        } else {
            $rpo_compliance = "Failed"
        }
            	

		$Object = New-Object PSObject -Property @{ 
			VM = $thisname
			Backups = $i.backups.count
			RPO_Compliance = $rpo_compliance
			RPA = "$($rpa.days)d $($rpa.hours)h"
			RPAspan = $rpa
			Type = $i.app_type #Physical or Virtual
		}

		$vmlist += $Object
	}

	$obj = $vmlist
	$prop = @('VM','RPO_Compliance','RPA','Backups')

	FormatUebResult $obj $prop
}
