function CheckConnection {
	if(!$global:UebAuthHeader)
	{
		throw "You are not currently connected to any server. Please connect first using  Connect-UebServer cmdlet. `r`n" 		
	}
}

function UebGet {
	param ([string] $api)

	Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method  Get -Headers $global:UebAuthHeader
}

function UebPost {
	param ([string] $api, $body)
	
	if($body -ne $null){
		Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method Post -Headers $global:UebAuthHeader -Body (ConvertTo-Json -InputObject $body -Depth 10 -Compress) 
	} else {
		Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method Post -Headers $global:UebAuthHeader
	}
}

function UebPut {
	param ([string] $api, $body)
	if($body -ne $null){
		Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method Put -Headers $global:UebAuthHeader -Body (ConvertTo-Json -InputObject $body -Depth 10) 
	} else {
		Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method Put -Headers $global:UebAuthHeader
	}
}

function UebDelete {
	param ([string] $api, $body)
	if($body -ne $null){
		Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method Delete -Headers $global:UebAuthHeader -Body (ConvertTo-Json -InputObject $body -Depth 10) 
	} else {
		Invoke-RestMethod -Uri "https://$global:UebServer/$api" -Method Delete -Headers $global:UebAuthHeader
	}
}

function Set-PSObjectDefaultProperties {
  param(
        [PSObject]$Object,
        [string[]]$DefaultProperties
       )
  $name = $Object.PSObject.TypeNames[0]     
  $xml = "<?xml version='1.0' encoding='utf-8' ?><Types><Type>"
  $xml += "<Name>$($name)</Name>"
  $xml += "<Members><MemberSet><Name>PSStandardMembers</Name><Members>"
  $xml += "<PropertySet><Name>DefaultDisplayPropertySet</Name><ReferencedProperties>"
  foreach( $default in $DefaultProperties ) {
      $xml += "<Name>$($default)</Name>"
  }
  $xml += "</ReferencedProperties></PropertySet></Members></MemberSet></Members></Type></Types>"
  $xml += ""
  $file = "$($env:Temp)\$name.ps1xml"
  Out-File -FilePath $file -Encoding "UTF8" -InputObject $xml -Force
  $typeLoaded = $host.Runspace.RunspaceConfiguration.Types | where { $_.FileName -eq  $file }
  if( $typeLoaded -ne $null ) {
      Write-Host "Type Loaded"
      Update-TypeData
  }
  else {
      Update-TypeData $file
      "loading now"
  }
}

function FormatUebResult{
	param(
		[object[]] $obj,  
		[object[]] $prop )

	if($obj) {
		$obj|%{
			$_.psTypeNames.Insert(0, "UebObject")
		}
	
		Update-TypeData -Force -TypeName "UebObject" -DefaultDisplayPropertySet $prop
		$obj
	}
}