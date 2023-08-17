function Close-ScriptLog {
    <#
        .SYNOPSIS
            Closes a ScriptLog.

        .DESCRIPTION
            Closes one (or all) active ScriptLogs, without touching the log files used by the log(s).

        .EXAMPLE
            Close-ScriptLog -Log $MyScriptLog 

            Closes the ScriptLog in $MyScriptLog

        .EXAMPLE
            Close-ScriptLog -All

            Closes all ScriptLogs

        .NOTES
            Author: kovergard
    #>
    [CmdletBinding(DefaultParameterSetName = 'SpecificLog')]
    [OutputType()]
    Param (
        # If specified, closes all ScriptLog objects
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'SpecificLog')]
        [ScriptLog]
        $Log,

        # If specified, closes all ScriptLog objects
        [Parameter(ParameterSetName = 'AllLogs')]
        [switch]
        $All
    )

    process {
        # If no ScriptLogs exists, silently return
        if ($Script:ScriptLogs.Count -eq 0) {
            Return
        }
        if ($All) {
            $Script:ScriptLogs | ForEach-Object { $_.Messages.Clear() }
            $Script:ScriptLogs.Clear()
            $Script:DefaultScriptLog = $null
        }
    }
}

