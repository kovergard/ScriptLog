function Remove-ScriptLog {
    <#
        .SYNOPSIS
            Removes a ScriptLog from memory.

        .DESCRIPTION
            Removes one (or all) active ScriptLogs from memory, without removing the log files that has been used by the log(s).

        .EXAMPLE
            Remove-ScriptLog -Name "MyLog"

            Removes the ScriptLog named "MyLog"

        .EXAMPLE
            Remove-ScriptLog -All

            Removes all ScriptLogs

        .NOTES
            Author: kovergard
    #>
    [CmdletBinding(DefaultParameterSetName = 'SpecificLog')]
    [OutputType()]
    Param (
        # ScriptLog object to remove
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'SpecificLog')]
        [String]
        $Name,

        # If specified, removes all ScriptLog objects
        [Parameter(ParameterSetName = 'AllLogs')]
        [switch]
        $All
    )
 
    process {
        # Remove all ScriptLogs if requested
        if ($All) {
            $Script:ScriptLogs | ForEach-Object { $_.Messages.Clear() }
            $Script:ScriptLogs.Clear()
            $Script:DefaultScriptLog = $null
        }
        else {
            $Log = $Script:ScriptLogs | Where-Object { $_.Name -eq $Name }
            if (-not $Log) {
                throw "Log with name '$Name' not found"
            }
            if ($Script:DefaultScriptLog -eq $Log) {
                $Script:DefaultScriptLog = $null
            }
            $Script:ScriptLogs.Remove($Log) | Out-Null
            $Log.Messages.Clear()
        }
    }
}

