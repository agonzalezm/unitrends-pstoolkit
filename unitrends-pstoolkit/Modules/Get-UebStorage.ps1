function Get-UebStorage {
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[string] $Name,
        [Parameter(Mandatory=$false)]
		[string] $Type
	)

    begin {
		CheckConnection
    }
	
	process {        
		$response = UebGet("/api/storage")
		$obj = $response.storage
    
		if($Name) {
			$obj = $obj | Where-Object { $_.name -like $Name }
		}
 
		if($Type) {
			$obj = $obj | Where-Object { $_.type -like $Type }
		}
        
		$prop = @('id','name','sid','system_name',
			'type','usage','stateless_type','status',
			'dedup','average_write_speed','mb_size',
			'mb_free','percent_used','daily_growth_rate',
			'warn_threshold','max_concurrent_backups',
			'compression','is_purging','is_expandable',
			'is_infinite','mb_to_purge','has_alert','alerts')
         
		FormatUebResult $obj $prop
	}
	
	end {
	}
}
