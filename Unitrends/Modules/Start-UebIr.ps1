<#
.Synopsis
   Starts a Unitrends Instant Recovery Job
.EXAMPLE
   
#>
function Start-UebIr {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
		$Server,
		$Name,
		$Datastore,
		$Directory,
		$BackupId,
		[switch] $Audit,
		[switch] $PowerOn,
		$Address
	)
	process {
		
		Write-Host "Audit: $Audit"
		Write-Host "PowerOn: $PowerOn"
		$target = New-Object PSObject -Property @{ 
				host = $Server
				name = $Name
		}

		if($Directory) {				
			$target |Add-Member directory $Directory				
		} else {
			$target |Add-Member datastore $datastore				
		}


		$Object = New-Object PSObject -Property @{ 
			address = $Address
			audit = if ($Audit) { $true } else { $false }
			poweron = if ($PowerOn) { $true } else { $false }
			backup_id = $BackupId							
			target = $target
		}
		
		$response = UebPost "api/restore/instant/?sid=1" $Object
	}
}

