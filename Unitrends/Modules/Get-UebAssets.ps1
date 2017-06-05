<#
.Synopsis
   Gets Assets from connected Unitrends Appliance
.DESCRIPTION
   This cmdlet returns the assets from the connected Unitrends Appliance.
   The output of this data is intended to match the output of the GUI on the CONFIGURE/Protected Assets screen.
   Use "Connect-UebServer" to connect.
.PARAMETER FULL
    Adds in the children of Hypervisor Machines.
.EXAMPLE
   Get-UebAssets -Full
#>
function Get-UebAssets{
    param(
        [switch]$full
    )
    # Get the basic data
  
    
$thisData = foreach ($item in (Get-UebApi -uri "/api/assets").data)
        {
        #If this item has no children
        if ($item.children -eq $null)
        {
            $item
        }
        ELSE # This item DOES have children
        {
            # Add the Parent Item
            $item
            if ($full)
                {
                # Add each childitem
                foreach ($child in $item.children)
                    {
                        $child
                    }
                }
        }
    }
    return $thisdata
}
