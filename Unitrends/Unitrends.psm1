Write-Host ""
Write-Host "[*] Welcome to Unitrends Powershell Toolkit! ---------------------------------------------------------"
Write-Host ""
Write-Host "    Sample usage:"
Write-Host ""
Write-Host "            Get-UebHelp"
Write-Host "            Connect-UebServer -Server ueb01 -User root -Password yourpass"
Write-Host "            Get-UebJob"
Write-Host "            Get-UebJob -Active"
Write-Host "            Get-UebJob -Recent"
Write-Host "            Get-UebJob -Active|Stop-UebJob"
Write-Host "            Get-UebJob -Active|Stop-UebJob"
Write-Host "            Get-UebJob -Name job1*|Start-UebJob"
Write-Host "            Get-UebJob -Name job1*|Disable-UebJob"
Write-Host "            Get-UebJob -Name job1*|Enable-UebJob"
Write-Host "            Get-UebAlert"
Write-Host "            Get-UebVirtualClient"
Write-Host ""
Write-Host ""
Write-Host "    Copyright (C) Unitrends,Inc. All rights reserved."
Write-Host "------------------------------------------------------------------------------------------------------"
Write-Host ""

Get-ChildItem $psscriptroot\Modules\*.ps1 | % { 
#	Write-Host $_.FullName 
	. $_.FullName
}

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
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls12