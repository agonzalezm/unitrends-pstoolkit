function Get-UebBackup {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
		$VM
	)

	CheckConnection
	
	$inst = $VM
	if($VM -is [String]) {
		$inst =  Get-UebCatalog -Name $VM
	}

	$obj = $inst.backups
	$prop = @('id','type','start_date','system_name')

	FormatUebResult $obj $prop
}