<#
.SYNOPSIS
Adds a Unitrends Backup job to the current Unitrends server
.DESCRIPTION
Uses the Unitrends API to create a new backup job.  Includes parameters to specify
the date/time/frequency of the job and the intial instances to be added to the job.
.PARAMETER Name
The name of the job
.PARAMETER Instances
An array of instance names.  These can be VMs or physical servers
.PARAMETER BackupType
The type of backup job to create
.PARAMETER EmailAddresses
An array of email addresses where the reports will be sent 
.PARAMETER StartDate
The start date of the first backup. Must be in datetime format and should include the month/day/year
.PARAMETER StartTime
The start time of the first backup. Must be in datetime format and should include hour / minute in 24-hour format
.PARAMETER RunOnDays
The days to run the backup. 0 = Sunday through 6 = Saturday
.PARAMETER BackupTarget
The storage where the backups will be stored.  Default is 'Internal'
.PARAMETER EmailReport
A switch that determines whether this job should be included in the Job Report
.PARAMETER FailureReport
A switch that determines whether this job should be included in the Failure Report
.PARAMETER LegalHoldBackups
A switch that determines whether this job should be have the LegalHoldBackups option set
.EXAMPLE 
New-UebBackupJob -Name "test-job" -instances @('server01') -StartDate "11/1/2016" -StartTime "23:46" -BackupType Incremental -EmailAddresses @("maybe-not-supported@acme.com")
Creates a scheduled incremental backup job
#>
Function New-UebBackupJob {
    [CmdletBinding()]
	param (       
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Collections.ArrayList]$Instances,
		[Parameter(Mandatory=$true)]
        [ValidateSet(“Full”,”Incremental”,”FullAndIncrementals”,"FullAndDifferentials")] 
		[string]$BackupType,
        [Parameter(Mandatory=$true)]
		[System.Collections.ArrayList]$EmailAddresses,
        [Parameter(Mandatory=$true)]
		[datetime]$StartDate,
        [Parameter(Mandatory=$true)]
		[datetime]$StartTime,
        [Parameter(Mandatory=$false)]
		[string]$BackupTarget="Internal",
        [Parameter(Mandatory=$false)]
        [bool]$EmailReport=$true,
        [Parameter(Mandatory=$false)]
        [bool]$FailureReport=$true,
        [Parameter(Mandatory=$false)]
        [bool]$LegalHoldBackups=$false,
        [Parameter(Mandatory=$false)]
        [ValidateRange(0,6)]
		[System.Collections.ArrayList]$RunOnDays=@(0,1,2,3,4,5,6)
	)

    ## Global Variables
    $instanceObjects = New-Object System.Collections.ArrayList
    $clientObjects = New-Object System.Collections.ArrayList

    ## Validate Input Data
    $jobOrders = (Get-UebApi "api/joborders").data

    #Check to see if a job with this name already exists
    If($jobOrders.name -contains "$Name"){
        Write-Error -Message "A job named $Name already exists in UEB"
        return
    }

    #Make sure the date/time specified is in the future
    If([datetime]"$($StartDate.ToString("MM/dd/yyy")) $($StartTime.ToString("HH:mm"))" -lt (Get-Date)){
        Write-Error -Message "The chosen start date/time has already passed.  Choose a start date/time in the future"
        return
    }

    #Email Addresses
    Foreach($EmailAddress in $EmailAddresses){
        Try{
            $try = [System.Net.Mail.MailAddress]$EmailAddress
        }
        Catch{      
            Write-Error -Message "$EmailAddress is not a valid email address"
            return
        }
    }

    #Instances
    Foreach ($instance in $Instances){
        if($instance -is [String]) {
            $object = Get-UebInventory -Name $instance | Select-Object -First 1
            If($object){
                if($object.asset_type -eq "physical")
                {
                    $client= @{ id = $object.id}
                    $clientObjects.Add($client)| Out-Null
                }
                else 
                {
                    $instanceObjects.Add($object) | Out-Null
                }
            }
            Else{
                Write-Warning -Message "Unable to find $instance in the UEB inventory. Skipping it for now."
            }
        }
        Else{
            $instanceObjects.Add($instance) | Out-Null
        }
    }

    If($instanceObjects.Count -eq 0 -and $clientObjects.Count -eq 0){
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
    $calendar = New-Object System.Collections.ArrayList

    $schedule = [pscustomobject] @{
        "run_on" = $RunOnDays
        "schedule_run" = 0
        "start_date" = "$(Get-Date -Date $StartDate -Format "MM/dd/yyy")"
        "start_time" = "$(Get-Date -Date $StartTime  -Format "HH:mm")"
        "backup_type" = "$BackupType"
    }

    $calendar.Add($schedule) | Out-Null

    $job = [pscustomobject] @{
        "name" = "$Name"
        "type" = "Backup"
        "calendar" = $calendar
        "storage" = "$BackupTarget"
        "clients" = [array]($clientObjects)
        "instances" = [array]($instanceObjects.id)
        "email_report" = $EmailReport
        "failure_report" = $FailureReport
        "legal_hold_backups" = $LegalHoldBackups
        "email_addresses" = $EmailAddresses
    }

    ## Call API
    $response = UebPost "api/joborders" $job
    $job
}