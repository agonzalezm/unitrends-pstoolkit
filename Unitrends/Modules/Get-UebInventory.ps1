function Get-UebInventory {
	param(
		[Parameter(Mandatory=$false)]
		[string] $Name
	)

	CheckConnection
	$response = UebGet("api/assets")

	$nodes = $response.data
	
	[array]$vms = $null
	
	foreach( $node in $nodes)
	{
		if($node.type -eq "VMware") #VMware
		{	
			foreach( $vm in $node.children)
			{
				$vm |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
				$vms += $vm
			}
		} elseif($node.type -eq "Windows") #Windows
		{
			$node |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
			$vms += $node

			foreach( $subnode in $node.children)
			{
				$subnode |Add-Member -MemberType NoteProperty -Name "server" -Value $node.name
				$vms += $subnode
			}		
		}
	}
	
	if($Name) {
		$vms= $vms | Where-Object { $_.name -like $Name }
	}
	
	$prop = @('name','server')
	FormatUebResult $vms $prop
}