function Get-UebCatalog {
	[CmdletBinding()]
	param(

	)

	CheckConnection
	
	$response = UebGet("api/catalog")
	$instances = $response.catalog.instances
	
	foreach($o in $instances){
		$lastbackup = $o.backups | Sort-Object -Property start_date -Descending| Select-Object -First 1
		$o | Add-Member –MemberType NoteProperty –Name last_backup_date –Value $lastbackup.start_date
		$o | Add-Member –MemberType NoteProperty –Name last_backup_id –Value $lastbackup.id	
	}
	$obj = $instances
	$prop = @('database_name','lbackup_date','last_backup_id','system_name')

	FormatUebResult $obj $prop
}