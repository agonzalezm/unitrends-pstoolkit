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
   Unitrends Appliance Password, in a string
.PARAMETER Credential
   Unitrends Appliance Username and Password in either PSCredential or domain\username format
.EXAMPLE
   Connect-UebServer -Server 192.168.1.100 -User root -Password 12345
.EXAMPLE
   Connect-UebServer -Server 192.168.1.100 -Credential 'domain\user'
.EXAMPLE
   Connect-UebServer -Server 192.168.1.100 -Credential $cred
.EXAMPLE
   Connect-UebServer -Server 192.168.1.100 -Credential (Get-Credential)
#>
function Connect-UebServer {
	[CmdletBinding(
        DefaultParameterSetName="PSCred"
    )]
	param (
		[Parameter(Mandatory=$true,Position=0)]
		[string] $Server,
        [Parameter(Mandatory=$true,Position=1, ParameterSetName="UserPass")]
		[string] $User,
		[Parameter(Mandatory=$true,Position=2, ParameterSetName="UserPass")]
        [string] $Password,
        [Parameter(Mandatory=$true,Position=3,ParameterSetName="PSCred")]
		[System.Management.Automation.CredentialAttribute()] $Credential

	)
    
    Switch ($PsCmdlet.ParameterSetName){   
        "UserPass" {            
            $body =  @{
		        username=$User;
		        password=$Password;
	        }
        }
        "PSCred" {            
            $body =  @{
		        username=$Credential.UserName;
		        password=$Credential.GetNetworkCredential().Password;
	        }
        }   
    } 

	$response = Invoke-RestMethod -Uri "https://$Server/api/login" -Method Post -Body (ConvertTo-Json -InputObject $body)
	$response

	$global:UebServer = $server
	$global:UebAuthHeader =  @{
		AuthToken=$response.auth_token;

	}

}