function Get-UebAlert {
	param()

	CheckConnection
	$response = UebGet("api/reports/system/alerts")

	$obj = $response.data
	$prop = @('sname','severity','created','message')

	FormatUebResult $obj $prop
}