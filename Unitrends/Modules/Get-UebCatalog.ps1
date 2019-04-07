function Get-UebCatalog {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[string] $Name,
		[Parameter(Mandatory=$false)]
		[string] $InstanceId,
		[Parameter(Mandatory=$false)]
		[int] $Days=30
	)

	CheckConnection
	$StartDate = (Get-Date).AddDays(-$Days).ToString("MM/dd/yyyy")

	if($InstanceId)
	{
		$iid_param = "&iid=" + $InstanceId
	}

	$response = UebGet("api/catalog/?start_date=" + $StartDate + $iid_param)
	

	$instances = $response.catalog.instances
	
	if($Name) {
		$instances = $instances | Where-Object { $_.database_name -like $Name -or $_.client_name -like $Name }
	}	


	foreach($o in $instances){
		$asset = ""
		if($o.database_name) {
			$asset = $o.database_name
			$asset_id = $o.instance_id
		} elseif($o.client_name) {
			$asset = $o.client_name
			$asset_id = $o.client_id
		}

		$lastbackup = $o.backups | Sort-Object -Property id -Descending| Select-Object -First 1
		$o | Add-Member -MemberType NoteProperty -Name last_backup_date -Value $lastbackup.start_date
		$o | Add-Member -MemberType NoteProperty -Name last_backup_id -Value $lastbackup.id
		$o | Add-Member -MemberType NoteProperty -Name asset -Value $asset
		$o | Add-Member -MemberType NoteProperty -Name asset_id -Value $asset_id		
	}
	$obj = $instances
	$prop = @('asset_id','asset','last_backup_date','system_name')

	FormatUebResult $obj $prop
}
