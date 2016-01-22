function Get-UebFlr {
	param()

	CheckConnection
	$response = UebGet("api/jobs/active/flr")

	$obj = $response.data
	$prop = @('id','instance_name','status','share_details')

	FormatUebResult $obj $prop
}

