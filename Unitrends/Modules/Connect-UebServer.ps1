<#
.Synopsis
   Establishes an authenticated server configuration
.DESCRIPTION
   Contacts server, uses username and password to retrieve an auth token. Server address and auth token get stored in global variables for consumption by related cmdlets.
.PARAMETER Server
   IP or URL of the target Unitrend Appliance.
.PARAMETER User
   Unitrends Appliance Username, in a string
.PARAMETER Password
   Unitrends Appliance Password
.EXAMPLE
   Connect-UebServer -Server 192.168.1.100 -username root -password 12345
#>
function Connect-UebServer {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true,Position=0)]
		[string] $Server,
        [Parameter(Mandatory=$true,Position=1)]
		[System.Management.Automation.CredentialAttribute()] $Credential

	)

	$body =  @{
		username=$Credential.UserName;
		password=$Credential.GetNetworkCredential().Password;
	}

	$response = Invoke-RestMethod -Uri "https://$Server/api/login" -Method Post -Body (ConvertTo-Json -InputObject $body)
	$response

	$global:UebServer = $server
	$global:UebAuthHeader =  @{
		AuthToken=$response.auth_token;
	}
}