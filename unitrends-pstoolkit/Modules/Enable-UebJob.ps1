function Enable-UebJob {
	[CmdletBinding()]
	param (
			[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[PSObject[]] $job
	)
	process {
		$id = $job.id
		$sid = $job.sid

		$response = UebPut "api/joborders/enable/$id/?sid=$sid" 
	}
}

