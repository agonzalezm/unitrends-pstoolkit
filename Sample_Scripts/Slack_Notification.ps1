########################################################################################
## To see what this looks like: https://s24.postimg.org/vjp7cydut/Unitrends_Slack.jpg ##
########################################################################################


#Get some info

$ueb = "<YOUR_UEB_HOSTNAME_OR_IP>"
$SlackToken = "<YOUR_SLACK_TOKEN>"


##Connect to the UEB

Import-Module Unitrends
Connect-UebServer -Server $ueb -User root -Password P@ssw0rd1


##Get failed jobs

$date = (Get-Date).AddDays(-1)
$results = (Get-UebJob -Recent).backups | Where-Object { ($_.start_time -gt $date) -and ($_.Status -ne 'Success')}


foreach ($result in $results) {

	$assetname = $result.asset_name
	$assetid = $result.instance_id
	$backupid = $result.backup_id
	$backuptype = $result.mode
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
						"value": "$assetname",
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
			"title": "Failure Message",
			"text": "$failuremessage",
			"color": "#CC0000"
			}
					]
	}
"@


##...and now for the bad news! 

Invoke-WebRequest `
	-Uri "https://hooks.slack.com/services/$SlackToken" `
	-Method "POST" `
	-Body $json

}
