function Remove-UebJobVm {
	[CmdletBinding()]
	param (
			[Parameter(Mandatory=$true)]
			$Job,
			[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
			$VM
	)
	process {
        $j = Get-UebJob -Name $Job
		$id = $j.id
		$sid = $j.sid
        $jobname = $j.name
		
		$joborder = (Get-UebApi "api/joborders/$id/?sid=$sid").data

        $addvm =  $VM	
        if($VM -is [String]) {
            $addvm =  Get-UebInventory.ps1 -Name $VM
		}
		$vmidstr = $addvm.id.split("_")[-1]

		[int]$vmid = [convert]::ToInt32($vmidstr, 10)
		
        $exists = $joborder.instances|Where-Object {$_.id -eq $vmid}

        if($exists) {
            $instances = {$joborder.instances}.Invoke()
            $instances.Remove($exists) 
   		    
            $joborder = $joborder | Select-Object -Property * -ExcludeProperty instances			
		    $joborder|Add-Member -MemberType NoteProperty -Name instances -Value $instances					

		    $response = UebPut "api/joborders/$id/?sid=$sid" $joborder
		
		    $joborder
        } else {
            Write-Warning "VM $($VM.name) is not included in job $jobname"
        }
	}
}

