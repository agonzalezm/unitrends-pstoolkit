clear
get-module
Remove-Module "Unitrends"
Import-Module $psscriptroot"\..\Unitrends.psd1"

#Connect-UebServer  -User root -Password pass -Server server
#Get-UebJob
#Get-UebVirtualClient
Get-UebJob | where-object {$_.name -like "Backup*"} | Start-UebJob