<#
.SYNOPSIS
Start on-demand backup
.DESCRIPTION
Uses the Unitrends API to start an on-demand backup
.PARAMETER Name
The name of the job
.PARAMETER Instances
An array of instance names.  These can be VMs or physical servers
.PARAMETER BackupType
The type of backup job to create
.PARAMETER BackupTarget
The storage where the backups will be stored.  Default is 'Internal'
.EXAMPLE 
Start-UebBackup -instances @('server01') -BackupType Incremental -BackupTarget "Internal"
#>
Function Start-UebBackup {

    [CmdletBinding()]
	param (      
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Collections.ArrayList]$Instances,

		[Parameter(Mandatory=$true)]
        [ValidateSet(“Full”,”Incremental”,”FullAndIncrementals”,"FullAndDifferentials")] 
		[string]$BackupType,

        [Parameter(Mandatory=$false)]
		[string]$BackupTarget="Internal"
	)


    $instanceObjects = New-Object System.Collections.ArrayList


    #Instances
    Foreach ($instance in $Instances){
        if($instance -is [String]) {
            $object = Get-UebInventory -Name $instance | Select-Object -First 1

            If($object){           
                $instanceObjects.Add($object) | Out-Null
            }
            Else{
                Write-Warning -Message "Unable to find $instance in the UEB inventory. Skipping it for now."
            }
        }
        Else{
            $object = Get-UebInventory -Id $instance | Select-Object -First 1

            If($object){           
                $instanceObjects.Add($object) | Out-Null
            }
            Else{
                Write-Warning -Message "Unable to find $instance in the UEB inventory. Skipping it for now."
            }
        }
    }

    

    If($instanceObjects.Count -eq 0){
        Write-Error -Message "There were no valid instances passed. Unable to continue"
        return
    }

    #BackupTarget Name
    If($BackupTarget -ne "Internal"){
        If(!(Get-UebApi "api/storage" | Where-Object {$_.name -eq $BackupTarget})){
            Write-Error -Message "$BackupTarget is not a valid UEB storage name"
            return
        }
    }

    ## Create Object for API Call             
    $job = [pscustomobject] @{

        "name" = "On-Demand"
        "type" = "Backup"
        "verify" = "none"
        "storage" = "$BackupTarget"
        "instances" = [array]($instanceObjects.id)
        "email_report" = "true"
        "failure_report" = "true"
        "backup_type" = "$BackupType"
    }

    ## Call API                       
    $response = UebPut "api/backups" $job

    $job
}