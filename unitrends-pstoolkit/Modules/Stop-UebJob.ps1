function Stop-UebJob {
	[CmdletBinding()]
	param (
			[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[PSObject[]] $job
	)
	process {
		$id = $job.id
		$sid = $job.sid

		$response = UebDelete "api/jobs/$id/?sid=$sid"
	}
}

