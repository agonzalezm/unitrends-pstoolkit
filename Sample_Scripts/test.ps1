
. ..\Unitrends\Init.ps1
Connect-UebServer -Server rc01 -User root 
New-UebBackupJob -Name "testjob2SR" -instances @('win01','wir02') -StartDate "3/27/2017" -StartTime "17:00" -BackupType Full -EmailAddresses @("agonzalez@unitrends.com")