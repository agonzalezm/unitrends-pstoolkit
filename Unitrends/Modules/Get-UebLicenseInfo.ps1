function Get-UebLicenseInfo {

	CheckConnection

	$response = UebGet("api/license")

	$obj = $response
	$prop = @('install_date','expiration_date','asset_tag','feature_string','class')

	FormatUebResult $obj $prop
}
