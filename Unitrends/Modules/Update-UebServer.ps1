<#
.Synopsis
   Updates appliance
.DESCRIPTION
    Update-UebServer
.EXAMPLE
    Update-UebServer -ssh -user root -passwd password
#>
function Update-UebServer {
	param(
        [Parameter(Mandatory=$false)]
        [string] $user,
        [Parameter(Mandatory=$false)]
        [string] $passwd,
        [Parameter(Mandatory=$false)]
        [switch] $ssh
    )


    if(!$ssh) {
        Write-Host "Updating... this operation may take some minutes dont close or abort this command until operation is finished"
        $result = UebPost "/api/updates/?sid=1"
        $result
    } else {
        $plink_path = $PSHome + "\Modules\unitrends\Modules\plink.exe"
        $plinkoptions = "-ssh $global:uebserver -P 22 -l root -pw $passwd -t"
        $plinkcmd = "yum update -y"  
        $plinkCommand  = [string]::Format('echo y | & "{0}" {1} "{2}"', $plink_path, $plinkoptions, $plinkcmd )
        Invoke-Expression $plinkCommand  
    }
}