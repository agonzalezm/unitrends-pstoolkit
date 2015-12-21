function Get-UebInventory {
	param(
		[Parameter(Mandatory=$false)]
		[string] $Name
	)

	CheckConnection
	$response = UebGet("api/inventory")

	$nodes = $response.inventory.nodes
	
	[array]$vms = $null
	
	foreach( $node in $nodes)
	{
		if($node.type_family -eq 202000) #VMware
		{	
			foreach( $vm in $node.nodes)
			{
				$vm |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
				$vms += $vm
			}
		} elseif($node.type_family -eq 2000) #Windows
		{
			foreach( $subnode in $node.nodes)
			{
				if($subnode.type_family -eq 201000)
				{
					foreach($vm in $subnode.nodes) {
						$vm |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
						$vms += $vm
					}
				}
			}		
		}
	}
	
	if($Name) {
		$vms= $vms | Where-Object { $_.name -like $Name }
	}
	
	$prop = @('name','server')
	FormatUebResult $vms $prop
}