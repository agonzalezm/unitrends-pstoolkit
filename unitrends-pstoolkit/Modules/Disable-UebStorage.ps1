function Disable-UebStorage {
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

		$response = UebPut "api/storage/offline/$id/?sid=$sid"
	}
	
	end {
	}
}
