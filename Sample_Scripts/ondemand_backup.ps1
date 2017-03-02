# The following Uses PowerCLI6 Import-Module and is intended to be run from console
# Add Snapin is needed to run this from Task Scheduler if vim.ps1 is not called
# add-pssnapin VMware.VimAutomation.Core
# add-pssnapin Unitrends
$Version = "1.2"
#######################################
#UEBAPI - STORE UEB CREDS AND RUN JOB #
#######################################
# Created by Tom Kolbe 28, Feb. 2017
#
# Version Changes:
# 1.0 - Initial Creation
# 1.1 - Code Reduction and Streamlining
# 1.2 - Job Validation
#######################################
#
# You can change the following defaults by altering the below settings:
#
#######################################
#             SET VARIABLES           #
#######################################
# UEB Server Instance
$UEBServer = "ueb1.local"
# Credential File
$UEBCred = "$pwd\uebuser.xml"
# Set Date
$Date = Get-Date
# Set EXEC Policy - Uncomment next 2 lines if you need to set the EXEC Policy or disable Certificate Validation
#Set-executionpolicy remotesigned -Confirm:$false
#Set-PowerCLIConfiguration -InvalidCertificateAction ignore -Confirm:$false
 
 
#######################################
#    NO CHANGES NEEDED BEYOND HERE    #
#######################################
#
#######################################
#    IMPORT VMWARE AND UEB MODULES    #
#######################################
Get-Module -Name VMware* -ListAvailable | Import-Module
# PowerCLI Set or install UEB Module
if (Get-Module -ListAvailable -Name Unitrends) {
    "Unitrends Module exists, loading..."
    Import-Module Unitrends
} else {
    "Unitrends Module does not exist, downloading..."
# Install UEB Module if not available and import   
if(!(Get-Module -Name Unitrends -ErrorAction SilentlyContinue)) {
 iwr https://raw.githubusercontent.com/Unitrends/unitrends-pstoolkit/master/Unitrends/Install.ps1 | iex
 Import-Module Unitrends
 }
}
 
######################################
#     SET UEB SERVER CREDENTIALS     #
######################################
$FileExists = Test-Path $UEBCred
 
If ($FileExists -eq $True) {
Write-Host "Credenial Store exists, let's continue..."
} else {
Write-Host "Credential Store does not exist, let's create one:"
# Ask UEB Username
$UEBUser = Read-Host -Prompt "Type in the UEB USERNAME for $($UEBServer)"
# Ask UEB User Pass
$UEBpass = Read-Host -Prompt "Type in the UEB $($User) Password"
# Create and Save Credential Store
New-VICredentialStoreItem -Host $UEBServer -File $UEBCred -User $UEBUser -Password $UEBpass
}
######################################
#  CONNECT WITH STORED CREDENTIALS   #
######################################
Write-Host "Connecting to UEB Instance..."
Get-VICredentialStoreItem -File $UEBCred | %{
Connect-UebServer -Server $UEBServer -User $_.User -Password $_.Password
}
Write-Host "You are now connected to the '$Server' server as '$User' on '$Date'"
 
######################################
#     SYNCHRONIZE UEB INVENTORY      #
######################################
Write-Host "============================================================"
Write-Host "Synchronizing UEB Inventory, please wait..."
Write-Host "============================================================"
Write-Host "`n"
Sync-UebInventory
 
######################################
#      GET ALL AVAILABLE JOBS        #
######################################
Write-Host "============================================================"
Write-Host "Getting a list of UEB Jobs..."
Write-Host "============================================================"
Write-Host "`n"
$a = @{Expression={$_.name};Label="Job Name";width=30}, `
@{Expression={$_.next_time};Label="Next Schedule";width=50}, `
@{Expression={$_.status};Label="Status";width=10}, `
@{Expression={$_.system_name};Label="UEB Server";width=30}
# Source: https://technet.microsoft.com/en-us/library/ee692794.aspx
 
Get-UebJob | Select-Object name,next_time,status,system_name | Format-Table $a?
 
# Print all variables using $GetJob = Write-Host $(Get-UebJob)
 
######################################
#        SET SELECTED JOB            #
######################################
Write-Host "============================================================"
Write-Host "Select a UEB Job to Run..."
Write-Host "============================================================"
Write-Host "`n"
$StartJob = Read-Host -Prompt "Which Job would you like to start on $($UEBServer)?"
$GetJob = Get-UebJob | Select-Object Name
$Validate = $GetJob.name -Contains $StartJob
if ($Validate -eq $False){
    "`n"
    "======================================================================="
    "WARNING: UEB Backup Job: '$($StartJob)' DOES NOT EXIST, now exiting..."
    "======================================================================="
    "`n"
} else {
 
######################################
#        RUN SELECTED JOB            #
######################################
Write-Host "`n"
Write-Host Starting Job $StartJob at $Date...
Get-UebJob -Name $StartJob | Start-UebJob
Write-Host "`n"
}