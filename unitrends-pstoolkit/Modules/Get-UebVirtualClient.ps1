function Get-UebVirtualClient {
	[CmdletBinding()]
	param(

	)

	CheckConnection
	
	$response = UebGet("api/virtual_clients")

	$obj = $response.data.wir.data
	$prop = @('virtual_id','vm_name','server_name','mode')
	$type = "UebVirtualClient"

	FormatUebResult $obj $type $prop
}