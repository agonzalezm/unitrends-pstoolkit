Param([switch]$alert,[switch]$backup,[switch]$catalog)

#----- DEFINE YOUR ENV SETTINGS"
$PSTOOLKIT_MODULES = "C:\Unitrends\unitrends-pstoolkit\Modules"
$SERVER = "192.168.11.20"
$USER = "root"
$PASSWD = "password"
#----- END OF USER CONFIGURATION


Get-ChildItem $PSTOOLKIT_MODULES\*.ps1 | % { . $_.FullName }

# ignore certs for https
add-type @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@
	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

Connect-UebServer -Server $SERVER  -User $USER -Password $PASSWD | Out-Null

$msg =""
$retval = 3

if($backup)
{    
    $status = Get-UebJob | Group-Object -Property last_status  


    foreach($s in $status)
    {
        $msg += $s.Name + "(" + $s.Count + ") "
    }

    if($msg -like "*Failed*" ) {
        $retval = 2
    } elseif($msg -like "*Never*") {
        $retval = 1
    } else {
        $retval = 0
    }
    
} elseif($alert) {
    $status = Get-UebAlert | Group-Object -Property severity   
    
    foreach($s in $status)
    {
        $msg += $s.Name + "(" + $s.Count + ") "
    } 
    
    if($msg -like "*critical*" ) {
        $retval = 2
    } elseif($msg -like "*warning*") {
        $retval = 1
    } else {
        $retval = 0
    }  
    
} elseif($catalog) {
    $status = Get-UebBackupSummary | Group-Object -Property RPO_Compliance   
    
    foreach($s in $status)
    {
        $msg += $s.Name + "(" + $s.Count + ") "
    } 
    
    if($msg -like "*Failed*" ) {
        $retval = 2
    } else {
        $retval = 0
    }  
}

Write-Host $msg.ToUpper()
exit $retval


