<#
.Synopsis
   Returns the number of protected assets that is required to provide the Unitrends MSP Program (for billing).
.DESCRIPTION
    Get-MSPAssetCount
.EXAMPLE
    Get-MSPAssetCount -ssh
#>
function Get-MSPAssetCount {
	param(
	[Parameter(Mandatory=$true,Position=2, ParameterSetName="UserPass")]
        [SecureString] $Password,
        [switch] $ssh
    )

        $passwd = (New-Object PSCredential "root",$Password).GetNetworkCredential().Password
        $plink_path = $PSHome + "\Modules\unitrends\Modules\plink.exe"
        $plinkoptions = "-ssh $global:uebserver -P 22 -l root -pw $passwd -t"
        $plinkcmd = @"
        psql -c postgres bpdb -c 'select count(distinct s.instance_id) as protected_assets from bp.successful_backups s inner join bp.nodes n using(node_no) inner join bp.application_instances ai using (instance_id) inner join bp.application_lookup al using (app_id) where al.app_id in (50, 51, 40, 1) and (now`()::date - 30) < (to_timestamp(s.start_time)::date);'
"@
        $plinkCommand  = [string]::Format('echo y | & "{0}" {1} "{2}"', $plink_path, $plinkoptions, $plinkcmd )
        $UebResult = Invoke-Expression $plinkCommand
        $UebResult.trim() | Select -index 4
}
