<#
.Synopsis
   Add protected asset
.DESCRIPTION
    Add-UebClient
.EXAMPLE
    Add-UebClient -ServerName win01 -ServerIp 192.168.11.91

#>
function Add-UebClient {
	param(
        [string] $ServerName,
        [string] $ServerIp
    )

        $body = @{
            name = $ServerName
            os_type = ""
            priority = 300
            is_enabled = $true
            is_synchable = $false
            use_ssl = $false
            install_agent = $false
            is_auth_enabled = $false
            is_encrypted = $false
            host_info = @{
                ip = $ServerIp
            }
            defaultschedule = $true
        }

        UebPost "api/clients/?sid=1" $body    
}