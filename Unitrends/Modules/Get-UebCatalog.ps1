function Get-UebCatalog {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[string] $Name
	)

	CheckConnection
	
	$response = UebGet("api/catalog")
	

	$instances = $response.catalog.instances
	
	if($Name) {
		$instances = $instances | Where-Object { $_.database_name -like $Name }
	}	

	foreach($o in $instances){
		$lastbackup = $o.backups | Sort-Object -Property start_date -Descending| Select-Object -First 1
		$o | Add-Member –MemberType NoteProperty –Name last_backup_date –Value $lastbackup.start_date
		$o | Add-Member –MemberType NoteProperty –Name last_backup_id –Value $lastbackup.id	
	}
	$obj = $instances
	$prop = @('instance_id','database_name','last_backup_date','system_name')

	FormatUebResult $obj $prop
}