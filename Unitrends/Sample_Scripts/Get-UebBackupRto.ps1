	param(
        $Name,
        $BackupId
	)

    #Change this settings for your default enviroment values
    $ESXHost = "38373035-3436-5a43-4a39-343430343745"
    $Datastore = "TINTRI"
    $UebIp = "192.168.11.20"
    #End of settings


	CheckConnection

    New-VIProperty -Name ToolsStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsStatus' -Force|Out-Null

    $start_date = Get-Date
	
    Write-Host " [*] Starting Unitrends Instant Recovery..."
    Start-UebIr -Host $ESXHost -Name $Name -Datastore $Datastore -BackupId $BackupId -Address $UebIp

    $ir = Get-UebIr

    while($ir.status -eq "running") {
        Sleep 5
        $ir = Get-UebIr
    }

    if($ir.status -ne "available" ) {
        Write-Error "Unitrends Instant Recovery Failed"
    }

    Write-Host " [*] Waiting for VMware tools to be ready..."
    
    $timeout = new-timespan -Minutes 5
    $sw = [diagnostics.stopwatch]::StartNew()
    
    $vm = Get-VM $Name
    while($vm.ToolsStatus -ne "toolsOk" -and $sw.elapsed -lt $timeout)
    {
        Sleep 5
        $vm = Get-VM $Name
    }

    if($vm.ToolsStatus -eq "toolsOk")
    {
        Write-Host "    $Name VMtools heartbeat is successful!"

        $end_date = Get-Date
        $rta = New-TimeSpan -Start $start_date -End $end_date
        Write-Host " [*] $Name RTA is $($rta.days)d $($rta.hours)h $($rta.minutes)m"
    } else {
        Write-Warning "    $Name VMtools heartbeat not OK: $($vm.ToolsStatus)"
        Write-Host " [*] $Name RTA is unavailable (vmtools didnt start)"
    }

    Write-Host " [*] Stopping Unitrends Intanst Recovery..."
    $stopir = Get-UebIr|Where-Object {$_.vm_name -eq $Name}
    Stop-UebIr -Id $stopir.virtual_id
