function Get-UebApi {
	param(
		[Parameter(Mandatory=$true)]
		[string] $uri
	)

	CheckConnection
	$response = UebGet($uri)

	$obj = $response.data
	$obj
}