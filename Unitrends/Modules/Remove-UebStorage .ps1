function Remove-UebStorage {
	[CmdletBinding()]
	param (
			[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[PSObject[]] $storage
	)
	
	begin {
		CheckConnection
    }
	
	process {
		$id = $storage.id
		$sid = $storage.sid

		$response = UebDelete "api/storage/$id/?sid=$sid"
	}
	
	end {
	}
}
