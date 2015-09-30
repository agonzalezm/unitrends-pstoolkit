function Get-UebAlert {
	param()

	CheckConnection
	$response = UebGet("api/reports/system/alerts")

	$obj = $response.data
	$prop = @('sname','severity','created','message')
	$type = "UebAlert"

	FormatUebResult $obj $type $prop
}