function Remove-ScriptLog {
    <#
        .SYNOPSIS
            Removes a ScriptLog from memory.

        .DESCRIPTION
            Removes one (or all) active ScriptLogs from memory, without removing the log files that has been used by the log(s).

        .EXAMPLE
            Remove-ScriptLog -Log $MyScriptLog 

            Removes the ScriptLog defined in $MyScriptLog

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
        [ScriptLog]
        $Log,

        # If specified, removes all ScriptLog objects
        [Parameter(ParameterSetName = 'AllLogs')]
        [switch]
        $All
    )
 
    process {
        # If no ScriptLogs exists, silently return
        if ($Script:ScriptLogs.Count -eq 0) {
            Return
        }
        # Remove all ScriptLogs if requested
        if ($All) {
            $Script:ScriptLogs | ForEach-Object { $_.Messages.Clear() }
            $Script:ScriptLogs.Clear()
            $Script:DefaultScriptLog = $null
        }
        else {
            if ($Script:DefaultScriptLog -eq $Log) {
                $Script:DefaultScriptLog = $null
            }
            $Script:ScriptLogs.Remove($Log) | Out-Null
            $Log.Messages.Clear()
        }
    }
}

