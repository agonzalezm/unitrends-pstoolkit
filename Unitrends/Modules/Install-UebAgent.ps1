<#
.Synopsis
   Install agent on windows server
.DESCRIPTION
    Install-UebAgent
.EXAMPLE
    Install-UebAgent -ServerName win01 -ServerIp 192.168.11.91 -User Administrator -Password passwod -Domain contoso -Agent windows

#>
function Install-UebAgent {
	param(
        [string] $ServerName,
        [string] $ServerIp,
        [string] $User,
        [string] $Password,
        [string] $Domain,
        [string] $Agent
    )

    if($Agent -eq "windows") {
        $body = @{
            name = $ServerName
            os_type = "Windows"
            priority = 300
            is_enabled = $true
            is_synchable = $false
            use_ssl = $false
            install_agent = $true
            is_auth_enabled = $true
            is_encrypted = $false
            credentials = @{
                display_name = $ServerName
                username = $User
                password = $Password
                domain = $Domain
                is_default = $false
            }
            host_info = @{
                ip = $ServerIp
            }
            defaultschedule = $true
        }

        UebPost "api/clients/?sid=1" $body
    }

}