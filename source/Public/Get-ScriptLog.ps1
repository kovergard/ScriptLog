function Get-ScriptLog {
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

        .NOTES
            Author: kovergard
    #>
    [CmdletBinding()]
    [OutputType([ScriptLog[]])]
    Param (
        # If specified, return only the default ScriptLog
        [Parameter()]
        [switch]
        $Default
    )

    process {
        if ($Default) {
            if (-not $DefaultScriptLog) {
                Write-Warning 'No ScriptLogs exists, cannot return default ScriptLog'
                break
            }
            return $DefaultScriptLog
        }
        return $ScriptLogs
    }
}
