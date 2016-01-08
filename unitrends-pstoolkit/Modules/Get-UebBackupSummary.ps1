function Get-UebBackupSummary {
	[CmdletBinding()]
	param(

	)

	CheckConnection
	
	$response = UebGet("api/catalog")
	$instances = $response.catalog.instances
	
	[array]$vmlist = $null
	$date = Get-Date
    $rpo = New-TimeSpan -Hours 24

	foreach($i in $instances){
		$lastbackup = $i.backups | Sort-Object -Property start_date -Descending | Select-Object -First 1
		$backup_date = [datetime] $lastbackup.start_date
		$rpa = New-TimeSpan -Start $backup_date -End $date	
        
        if($rpa -le $rpo) {
            $rpo_compliance = "OK"
        } else {
            $rpo_compliance = "Failed"
        }
            	

		$Object = New-Object PSObject -Property @{ 
			VM = $i.database_name
			Backups = $i.backups.count
			RPO_Compliance = $rpo_compliance
			RPA = "$($rpa.days)d $($rpa.hours)h"
			RPAspan = $rpa
		}

		$vmlist += $Object
	}

	$obj = $vmlist
	$prop = @('VM','RPO_Compliance','RPA','Backups')

	FormatUebResult $obj $prop
}