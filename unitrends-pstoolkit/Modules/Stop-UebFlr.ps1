function Stop-UebFlr {
	param (
			[String] $FlrId
	)

		$response = UebDelete "api/jobs/$FlrId/?sid=1"
}

