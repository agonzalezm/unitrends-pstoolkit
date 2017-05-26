param (
    [int] $days,
    [string] $report

)

# User settings
$ueb = "rc01"
$user = "root"
$pass = "password"

#Mail settings
$smtp = "unitrends-com.mail.protection.outlook.com"
$smtp_user = "<user>"
$smtp_pass = "<pass>"
$ssl=$false
#use ssl for gmail/office365
$port=587
$from = "report@unitrends.com"
$to = "<mail>"
$body = "Report is attached"
$subject = "unitrends mail report"
# End of user settings

# Report URL
#$report = "api/reports/storage/status/"
#$report = "api/reports/backup/failure/"



##Script code
Import-Module Unitrends
Connect-UebServer -Server $ueb -User $user -Password $pass

$report = $report + "/?format=pdf"
if($days)
{
    $StartDate = (Get-Date).AddDays(-$days).ToString("MM/dd/yyyy")
    $report = $report + "&start_date=" + $StartDate
}

$temp_file = $env:temp + "\report.pdf"
$data = Get-UebApi -uri $report
Invoke-WebRequest -Uri $data.pdf_url -OutFile $temp_file
Write-Host $temp_file

#send mail
$creds = New-Object System.Management.Automation.PSCredential($smtp_user, (ConvertTo-SecureString $smtp_pass -AsPlainText -Force))

if($ssl)
{
    Send-MailMessage -From $from -to $to -Subject $subject -Body $body -SmtpServer $smtp -Attachments $temp_file -usessl -Credential $creds -Port 587
}  else {
    Send-MailMessage -From $from -to $to -Subject $subject -Body $body -SmtpServer $smtp -Attachments $temp_file
}

