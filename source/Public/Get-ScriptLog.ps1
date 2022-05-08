<#
.SYNOPSIS
    Returns active ScriptLogs.
.DESCRIPTION
    Returns a list of all active ScriptLogs.
.EXAMPLE
    Get-ScriptLog
    Returns a list of all active ScriptLogs
.EXAMPLE
    Get-ScriptLog -Default
    Returns the default ScriptLog
.INPUTS
    None. You cannot pipe objects to Get-ScriptLog.
.OUTPUTS
    ScriptLog[]. Get-ScriptLog returns one or more ScriptLogs.
#>
function Get-ScriptLog
{
    [CmdletBinding()]
    Param (
        # If specified, return only the default ScriptLog
        [Parameter()]
        [switch]
        $Default
    )

    process
    {
        if ($Default)
        {
            if (-not $DefaultScriptLog)
            {
                Write-Warning 'No ScriptLogs exists, cannot return default ScriptLog'
                break
            }
            return $DefaultScriptLog
        }
        return $ScriptLogs
    }
}
