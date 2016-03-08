function Add-UebStorage {
	[CmdletBinding()]
	param (
			[Parameter(Mandatory=$false, ValueFromPipeline=$true)]
			[String]
			[alias("id")]
			$sid,
			
			[Parameter(Mandatory=$true)]
			[String]
			$Name,
			
			[Parameter(Mandatory=$true, HelpMessage="Usage: stateless, backup, archive ,source")]
			[ValidateSet("stateless","backup","archive","source")]
			[String]
			$Usage,
			
			[Parameter(Mandatory=$true, ParameterSetName="nas")]
			[switch]
			$nas,
			
			[Parameter(Mandatory=$true, ParameterSetName="iscsi")]
			[switch]
			$iscsi,
			
			[Parameter(Mandatory=$true, ParameterSetName="nas")]
			[Parameter(Mandatory=$true, ParameterSetName = "iscsi")]
			[String]
			$Hostname,

			[Parameter(Mandatory=$false, ParameterSetName="nas")]
			[Parameter(ParameterSetName = "iscsi")]
			[String]
			$Port		= "445",
			
			[Parameter(Mandatory=$true, ParameterSetName="nas")]
			[String]
			$Share_name,
			
			[Parameter(Mandatory=$true, ParameterSetName="nas")]
			[ValidateSet("nfs", "cifs")]
			[String]			
			$Protocol ,
			
			[Parameter(Mandatory=$false, ParameterSetName="nas")]
			[String]
			$Username,
			
			[Parameter(Mandatory=$false, ParameterSetName="nas")]
			[String]			
			$Password,
			
			[Parameter(Mandatory=$true, ParameterSetName="iscsi")]
			[String]			
			$Target,
			
			[Parameter(Mandatory=$true, ParameterSetName="iscsi")]
			[String]			
			$Lun
	)
	
	begin {
		CheckConnection
    }
	
	process {
	
		if (!$sid) {
			$UebSystems = Get-UebSystems -local
			$sid = $UebSystems.id
		}

		if ($nas) {
			$Type = 4
			$StoregeProb = New-Object PSObject -Property @{            
				hostname    = $Hostname
				port		= $Port
				share_name  = $Share_name
				protocol	= $Protocol
				username	= $Username
				password	= $Password
			}                        	
		}
		elseif($iscsi)
		{
			$Type = 1
			$StoregeProb = New-Object PSObject -Property @{            
				hostname    = $Hostname
				port		= $Port
				target	    = $Target
				lun			= $lun
			}
		}

		$StoregeObj = New-Object PSObject -Property @{            
			name    	= $Name
			type		= $Type
			usage	    = $Usage
			properties	= $StoregeProb
        }
		
		$response = UebPost "api/storage/?sid=$sid" $StoregeObj
		
		$response.result
	}
	
	end {
	}
}
