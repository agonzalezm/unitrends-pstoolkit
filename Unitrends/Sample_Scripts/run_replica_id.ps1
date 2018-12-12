param(
    $instance = 238,
    [switch] $RestoreOnly = $false,
    [switch] $ImportOnly = $false,
    [string] $ImportPath
)

#--- user settings ------
#ueb from where to restore backups
$ueb = "ueb02"
$user = "root"
$pass = "password"
#hyperv client to restore to replicas
$client_id=6
$replica_name_prefix="customer1"
$restore_path="C:/vmtest/replica/"
$switch_name="test-vswitch"
#--- end of user settings ------

# main code, dont modify

$ErrorActionPreference = 'Stop'

if (!(Test-Path "$restore_path/logs" -PathType Container)) {
    New-Item -ItemType Directory -Force -Path "$restore_path/logs"
}

 
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information',
        
        [Parameter()]
        [switch]$Init
    )

    $date = (Get-Date -f g)
    $log = $restore_path + "logs/" + $instance
    if($Init) {
        if (Test-Path $log)
        {
            Remove-Item $log -Force 
        }
    }

    "$date - [$severity] - $Message" | Out-File -Append -FilePath $log    
}

trap [Exception] {
      Write-Log -Severity Error -Message $("TRAPPED: " + $_.Exception.Message);
	  Write-Log -Severity Error -Message "ERROR:"
	  Write-Log -Severity Error -Message $_.InvocationInfo.PositionMessage
      Write-Log -Severity Error -Message "ExitCode: 9"
      Write-Error -Message "TRAPPED: $_.Exception.Message" -ErrorAction Continue
      Write-Error -Message $_.InvocationInfo.PositionMessage -ErrorAction Continue
      exit 9
}	

# functions


function Get-ParentPath {
    Param([String]$VHDPath)

    Write-Log -Message "Getting disk information for file $VHDPath"

	$VHDSVC = Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_ImageManagementService -ErrorAction Stop
    $VHDInfo = [xml]$VHDSVC.GetVirtualHardDiskSettingData($VHDPath).SettingData
	
    if ($VHDInfo) {
		$ParentPath = ($VHDInfo.INSTANCE.PROPERTY | Where { $_.Name -eq "ParentPath" }).Value
        if ($ParentPath) { 
			$Result = $VHDPath,$ParentPath 
            While ($ParentPath.Split(".")[1] -match "avhd") {
				$VHDInfo = [xml]$VHDSVC.GetVirtualHardDiskSettingData($ParentPath).SettingData
                $ParentPath = ($VHDInfo.INSTANCE.PROPERTY | Where { $_.Name -eq "ParentPath" }).Value
                $Result += $ParentPath
            }
            
			Write-log -Message "Got disk chain information:"
            $Result | % { Write-Log -Message "  $_" }
        } else {
			$Result = $VHDPath  
            Write-Log -Message "Disk '$Result' is not a differencing disk - does not have any parent.." 
        }
    } else {
		Write-Log -Message "Disk file '$VHDPath' does not exist" 
    }
    
	$Result
}

function Merge-VMDisks {    

    Param( [Microsoft.HyperV.PowerShell.VirtualMachine] $VM)
    
    $VMDisks = $VM | Get-VMHardDiskDrive

    foreach ($Disk in ($VMDisks | Where { $_.Path -match ":" })) {
        $vdisk_path = $Disk.Path

        if(!(Test-Path $vdisk_path)) {
            # the disk in the config file doesnt exists lets see if there is an autorevery disk and use it.
            Write-Log -Message "The Disk '$($vdisk_path)' doesnt exist. Checking for -AutoRecovery disk..."
	    
	    if($vdisk_path.Contains(".avhdx")) { 
                $autorecovery_disk = $vdisk_path.Substring(0,$vdisk_path.Length - 43) + "-AutoRecovery.avhdx"
            } else { 
                $autorecovery_disk = $vdisk_path.Substring(0,$vdisk_path.Length - 42) + "-AutoRecovery.avhd"
            }
            
            if(Test-Path $autorecovery_disk){
                $vdisk_path = $autorecovery_disk
		Write-Log -Message "AutoRecovery disk found, it will be used for merge ..."
            } else {
                throw "The disk used in config file $vdisk_path or $autorecovery_disk doesnt exists. Cant continue."
            }
        }

        $DiskTree = Get-ParentPath -VHDPath $vdisk_path
        if ($DiskTree.Count -gt 1) { 
            Write-Log -Message "Processing Disk '$($vdisk_path)'"
            for ($i=0; $i -lt $DiskTree.Count-1; $i++) {
                Write-Log -Message "  Merging file '$($DiskTree[$i])' # $($i+1) of $($DiskTree.Count-1) .." 
                Merge-VHD -Path $DiskTree[$i] -Confirm:$false -Force
            }
                
            $new_path = $DiskTree[$DiskTree.Count-1]
            Write-Log -Message "Setting disk path to $new_path .." 
            Set-VMHardDiskDrive -VMHardDiskDrive $Disk -Path $new_path
        }    
    }           
 } 

function Restore {
    Write-Log -Message "Starting Restore"
    Import-Module Unitrends
    Connect-UebServer -Server $ueb -User $user -Password $pass | Out-Null
    
    $catalog = Get-UebCatalog -InstanceId $instance
    $backup_date = [datetime]::Parse($catalog.last_backup_date).ToString("yyyyMMdd_HHmmss")
    $backup_id = $catalog.last_backup_id
    $vm_name = $replica_name_prefix + "_" + $catalog.asset_id + "_" + $catalog.asset + "_" + $backup_date
    $directory = $restore_path + $vm_name
    $directory = $directory -replace " ","_"
    $directory_temp = $directory + "\unitrends_restore"
    
    $vm = Get-VM|where-object {$_.name -eq $vm_name}
    if($vm)
    {
        Write-Progress -Id $instance -Activity $instance -Status "Last backup is already restored. VM ($vm_name) already exists with backup_id $backup_id"  -PercentComplete 100 -completed
        Write-Warning "Last backup is already restored. VM ($vm_name) already exists with backup_id $backup_id"
        sleep 5
        exit 0
    }
      
    if (Test-Path $directory -PathType Container) {
        Remove-Item -Path $directory -Recurse -Force
    }
    
    Write-Progress -Id $instance -Activity $instance -Status "Restoring backup_id $backup_id to $directory_temp"  -PercentComplete 0 -completed
    
    $restore = Start-UebRestoreFile -backupID $catalog.last_backup_id -clientID $client_id -directory $directory_temp -flat $false -synthesis $false
    $restore_id = $restore.id
    
    $restore_job = $null
    while($restore_job -eq $null) {
        $restore_job = get-uebjob -Active|Where-Object {$_.id -eq $restore_id}
        Sleep 3
    }
    
    while($restore_job.status -eq "Queued" -or $restore_job.status -eq "Active" -or $restore_job.status -eq "Connecting")
    {
        Write-Progress -Id $instance -Activity $instance -Status "Restoring backup_id $backup_id to $directory_temp"  -PercentComplete $restore_job.percent_complete
        $restore_job = get-uebjob -Active|Where-Object {$_.id -eq $restore_id}
        Sleep 3
    }
    
    Write-Progress  -Id $instance -Activity $instance -Status "Restoring backup_id $backup_id to $directory_temp"  -PercentComplete 100 -completed
    
    # restore complete,change vm id, remove saved state, change disk path and register vm or other import incompatibilities
    Write-Progress  -Id $instance -Activity $instance -Status "Import VM as $vm_name"  -PercentComplete 100 -completed    

    return ,$directory
}

function Import
{
    param([string]$directory)

    Write-Log -Message "Starting Import"
    $vm_name = $directory|split-path -leaf
    $directory=$directory -replace "/","\"
    $directory_temp = $directory + "\unitrends_restore"     

    #check for open snapshots
    $xml_file = Get-ChildItem -Path $directory_temp -Recurse -include *.xml | Where-Object { $_.DirectoryName.EndsWith("Virtual Machines")}
    if($xml_file.Count -eq 1)
    {
        $content = Get-Content $xml_file
        if($content|Select-String "\.avhd|\.avhdx")
        {
            #Write-Warning "Restored backup contains open snapshots files and is not suported"
            #Exit 1   
        }
    } else 
    {
        Write-Warning "Restored backup contains more than one .xml file in Virtual Machines folder"
        Exit 1
    }

    #$vm_dir = Get-ChildItem -Path $directory_temp -Recurse| Where-Object {$_.PsIsContainer -eq $True}| Where-Object {$_.FullName.EndsWith("Virtual Machines")}
    #Move-Item -Path $vm_dir.FullName -Destination $directory
    
    #move config files from Virtual Machines
    if (Test-Path "$directory/config" -PathType Container) {
        Remove-Item -Path "$directory/config" -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path "$directory/config"
    $files = Get-ChildItem -Path $directory_temp -Recurse -include *.xml,*.preCheckpointCopy,*.vmrs | Where-Object { $_.DirectoryName.EndsWith("Virtual Machines")}
    foreach($file in $files)
    {
        Copy-Item -Path $file.FullName -Destination "$directory/config"
    }

    #move vhd, vhdx rom temp restore dir to final dir
    $files = Get-ChildItem -Path $directory_temp -Recurse -include *.vhd,*.vhdx,*.avhd,*.avhdx
    foreach($file in $files)
    {
        Move-Item -Path $file.FullName -Destination $directory
    }


    $new_guid = [guid]::NewGuid().ToString().ToUpper()

    # check if restored VM is vmcx (hv2016) or xml (hv2012)
    $vmcx = Get-Item -Path "$directory\config\*.preCheckpointCopy"
    $vm_config = ""
    if($vmcx)  {
        $vm_config = $new_guid + ".vmcx"
        $new_vmrs = $new_guid + ".vmrs"
        Remove-Item -Path "$directory\config\*.vmcx"
        Rename-Item  $vmcx -NewName $vm_config
        $vmrs = Get-Item -Path "$directory\config\*.vmrs"
        Rename-Item  $vmrs -NewName $new_vmrs
    } else  {
        $vm_config = $new_guid + ".xml"
        $xml = Get-Item -Path "$directory\config\*.xml"
        Rename-Item -Path $xml -NewName $vm_config
    }

    $vm_config = $directory + "\config\" + $vm_config

    sleep 5

    $report = Compare-VM  -Path $vm_config -Register
    Write-Log -Message "Compare-VM Incompatibilities: $($report.Incompatibilities|Out-String)"
    $report.VM|Remove-VMSavedState -ErrorAction Ignore
    $report.VM|rename-vm -NewName $vm_name
    $report.VM|Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $switch_name

    # wait 3 secs to saved state to be removed
    Sleep 5

    # set harddisk location to restored folder
    $vhds = $report.VM | Get-VMHardDiskDrive
    foreach($vhd in $vhds)
    {
        $path = $vhd.Path
        $vhd_name = $path.Substring($path.LastIndexOf("\"))
        
        $new_path = $directory + $vhd_name
        Write-Host $new_path
        Set-VMHardDiskDrive -VMHardDiskDrive $vhd -Path $new_path #�ControllerType $vhd.ControllerType �ControllerNumber $vhd.ControllerNumber -ControllerLocation $vhd.ControllerLocation
    }

    Merge-VMDisks -VM $report.VM
    $report.VM|Get-VMSnapshot|Remove-VMSnapshot

    Import-VM $report

    Remove-Item -Path $directory_temp -Recurse -Force
}

function CleanUp {
    # remove previous restores
    $vm_prefix = $replica_name_prefix + "_" + $catalog.asset_id + "_" + $catalog.asset + "_*"
    $vms = get-vm -name $vm_prefix|Sort-Object -Descending|Select-Object -Skip 1

    foreach ($vm in $vms)
    {
        Remove-VM -VM $vm -Force
        $remove_dir = $restore_path + $vm.name
        Remove-Item -Path $remove_dir -Recurse -Force
    }

    #remove orphaned folders
    $folder_path = $restore_path + $vm_prefix 
    $folders = Get-Item $folder_path|Sort-Object -Descending -Property name|Select-Object -Skip 1
    foreach ($folder in $folders)
    {
        Remove-Item -Path $folder -Recurse -Force
    }
}

# Main()
#.\run_replica_id.ps1
#.\run_replica_id.ps1 -RestoreOnly
#.\run_replica_id.ps1 -ImportOnly -ImportPath "c:\vmtest\replica\ueb02_378_nano01_20181122_231813"
#$vm_name = "ueb02_378_nano01_20181122_231813"
#$directory = $restore_path + $vm_name

Write-Log -Message "Main(): Start" -Init

# Restore
if($ImportOnly -eq $false) {
    $directory = Restore
} else {
    $directory = $ImportPath
}

if($RestoreOnly -eq $true) { 
    return
}

#Import
Import $directory 

if($ImportOnly -eq $true) { 
    return
}

#CleanUp
CleanUp
