##Get Some info

$ueb = '100.10.10.5'
$uebUSER = 'root'
$uebPASS = 'xxxxxxx'

$drift = '1800'
$SlackWebHook = 'https://hooks.slack.com/services/xxxxxx/yyyyyyyyyy/zzzzzzzzzzzzzzz'

##Connect to the UEB
Import-Module Unitrends
Connect-UebServer -Server $ueb -User $uebUSER -Password $uebPASS


##Get failed jobs
$time=[Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
$results = ((Get-UebApi -uri api/jobs/history?showFlat=true).data |?{$_.sort_start_time -gt ($time - $drift) -and ($_.Status -ne 'Success')})

foreach ($result in $results) {

  $clientname = $result.client_name
  $assetname = $result.asset_name
  $assetid = $result.instance_id
  $backupname = $result.name
  $backupid = $result.backup_id
  $backuptype = $result.mode
  $description = $result.description
  $starttime = $result.start_time
  $status = $result.status
  $failuremessage = $result.message

$json = @"
{
  "text": "*BACKUP FAILURE ON $ueb*",
  "attachments": [
  {
  "color": "#636363",
  "fields": [
  {
  "title": "Server",
  "value": "$clientname",
  "short": true
  },
  {
  "title": "Application/Database",
  "value": "$assetname",
  "short": true
  },
  {
  "title": "Job Name",
  "value": "$backupname",
  "short": true
  },
  {
  "title": "Job Description",
  "value": "$description",
  "short": true
  },
  {
  "title": "Job Start Time",
  "value": "$starttime",
  "short": true
  },
  {
  "title": "Job Type (ID)",
  "value": "$backuptype ($backupid)",
  "short": true
  },
  {
  "title": "Job Status",
  "value": "$status",
  "short": true
  }
  ]
  },
  {
  "title": "Message",
  "text": "$failuremessage",
  "color": "#CC0000"
}
]
}
"@


##Send Results to Slack…

Invoke-WebRequest `
	-Uri "$SlackWebHook" `
	-Method "POST" `
	-Body $json

}
