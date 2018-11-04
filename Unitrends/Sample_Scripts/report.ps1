param(
    [Parameter(Mandatory=$true,Position=0)]
    [string] $File
)

# User settings
$ueb = "ueb01"
$user = "root"
$pass = "password"

Import-Module Unitrends
Connect-UebServer -Server $ueb -User $user -Password $pass | Out-Null

