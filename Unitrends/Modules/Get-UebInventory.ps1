function Get-UebInventory {
	param(
		[Parameter(Mandatory=$false)]
		[string] $Name,
		[Parameter(Mandatory=$false)]
		[string] $Id

	)

	CheckConnection
	$response = UebGet("api/assets")

	$nodes = $response.data
	
	[array]$vms = $null
	
	foreach( $node in $nodes)
	{
		$node |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
		$vms += $node

		foreach( $subnode in $node.children)
		{
			$subnode |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
			$vms += $subnode

			foreach( $subnode2 in $subnode.children)
			{
				$subnode2 |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
				$vms += $subnode2
			}		
	
		}		



	}
	
	if($Name) {
		$vms= $vms | Where-Object { $_.name -like $Name }
	}

	if($Id) {
		$vms= $vms | Where-Object { $_.id -like $Id }
	}
	
	$prop = @('id','name','server')
	FormatUebResult $vms $prop
}