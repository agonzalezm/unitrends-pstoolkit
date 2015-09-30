if($PSVersionTable.PSVersion.Major -lt 3) {
	throw "Unitrends Powershell Toolkit requires Powershell 3.0 or higher. You are running Powershell v" + $PSVersionTable.PSVersion
}

Remove-Module Unitrends -ErrorAction:SilentlyContinue
Import-Module $psscriptroot\Unitrends.psd1
