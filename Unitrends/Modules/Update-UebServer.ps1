<#
.Synopsis
   Updates appliance
.DESCRIPTION
    Update-UebServer
.EXAMPLE
    Update-UebServer -ssh
#>
function Update-UebServer {
	param(
		[Parameter(Mandatory=$true,Position=2, ParameterSetName="UserPass")]
        [SecureString] $Password,
        [switch] $ssh
    )

    
    if(!$ssh) {
        Write-Host "Updating... this operation may take some minutes dont close or abort this command until operation is finished"
        $result = UebPost "/api/updates/?sid=1"
        $result
    } else {
        $passwd = (New-Object PSCredential "root",$Password).GetNetworkCredential().Password
        $plink_path = $PSHome + "\Modules\unitrends\Modules\plink.exe"
        $plinkoptions = "-ssh $global:uebserver -P 22 -l root -pw $passwd -t"
        $plinkcmd = "yum update -y"  
        $plinkCommand  = [string]::Format('echo y | & "{0}" {1} "{2}"', $plink_path, $plinkoptions, $plinkcmd )
        Invoke-Expression $plinkCommand  
    }
}