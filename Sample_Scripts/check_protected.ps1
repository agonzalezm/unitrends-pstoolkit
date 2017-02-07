# This script will check a list of hosts to see if they are registered in unitrends appliances
# You can build this list from AD per example, using AD powershell cmdlet:
#   PS > Get-ADComputer -Filter * -Properties ipv4Address|Select-Object -Property ipv4address| Out-File -FilePath c:\adcomputers.txt
# You can copy that file and then pass as a parameter to this script

param(
    [Parameter(Mandatory=$true,Position=0)]
    [string] $File
)

# User settings
$ueb = "rc01"
$user = "root"
$pass = "password"

Import-Module Unitrends
Connect-UebServer -Server $ueb -User $user -Password $pass | Out-Null


$ips = Get-Content $File|where {$_.trim() -ne ""}
$asset_ips = (get-uebapi -uri /api/assets).data.ip
[array]$list = New-Object System.Collections.ArrayList

foreach($ip in $ips) {
    if(!$asset_ips.Contains($ip))
    {   
        $client = New-Object psobject
        $client|add-member -membertype NoteProperty -Name "ip" -Value $ip
        $client|add-member -membertype NoteProperty -Name "protected" -Value $false
        $list += $client
        #Write-Host "$ip is not protected"
    } 
    else 
    {
        $client = New-Object psobject
        $client|add-member -membertype NoteProperty -Name "ip" -Value $ip
        $client|add-member -membertype NoteProperty -Name "protected" -Value $true
        $list += $client
        #Write-Host "$ip is protected"
    }
}

$list|Format-Table
