param (
)

#--- user settings ------
$instances=@(378,392)
#--- end of user settings ------

## Script code
$ScriptFile="./run_replica_id.ps1"
#functions
function Show-JobProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Job[]]
        $Job
    )

    Process {
        $Job.ChildJobs | ForEach-Object {
            if (-not $_.Progress) {
                return
            }

            $_.Progress |Select-Object -Last 1 | ForEach-Object {
                $ProgressParams = @{}
                if ($_.Activity          -and $_.Activity          -ne $null) { $ProgressParams.Add('Activity',         $_.Activity) }
                if ($_.StatusDescription -and $_.StatusDescription -ne $null) { $ProgressParams.Add('Status',           $_.StatusDescription) }
                if ($_.CurrentOperation  -and $_.CurrentOperation  -ne $null) { $ProgressParams.Add('CurrentOperation', $_.CurrentOperation) }
                if ($_.ActivityId        -and $_.ActivityId        -gt -1)    { $ProgressParams.Add('Id',               $_.ActivityId) }
                if ($_.ParentActivityId  -and $_.ParentActivityId  -gt -1)    { $ProgressParams.Add('ParentId',         $_.ParentActivityId) }
                if ($_.PercentComplete   -and $_.PercentComplete   -gt -1)    { $ProgressParams.Add('PercentComplete',  $_.PercentComplete) }
                if ($_.SecondsRemaining  -and $_.SecondsRemaining  -gt -1)    { $ProgressParams.Add('SecondsRemaining', $_.SecondsRemaining) }

                Write-Progress @ProgressParams
            }
        }
    }
}


#main code

get-job|remove-job
foreach ($instance in $instances) {
    Start-Job -FilePath $ScriptFile -ArgumentList $instance -Name $instance|Out-Null
}

While ($(Get-Job -State Running).count -gt 0){
    Get-Job|Show-JobProgress
    Start-Sleep -Seconds 3
}

#Get-Job|Wait-Job
#Write-Host "End of all jobs"
#Get-Job| Receive-Job | Select-Object * -ExcludeProperty RunspaceId | out-gridview