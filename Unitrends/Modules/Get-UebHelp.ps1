function Get-UebHelp {
	param()

    gci -exclude "Helper.ps1" C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Unitrends\Modules\|Select @{ expression={$_.BaseName}; label='Unitrends Cmdlets' }

}