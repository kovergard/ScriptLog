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
            Get-ScriptLog -Name "SomeLog"

            Returns the ScriptLog named "SomeLog"

        .EXAMPLE
            Get-ScriptLog -Default

            Returns the default ScriptLog

        .NOTES
            Author: kovergard
    #>
    [CmdletBinding(DefaultParameterSetName = 'AllLogs')]
    [OutputType([ScriptLog[]])]
    Param (
        # Find ScriptLog object by name
        [Parameter(ValueFromPipeline, ParameterSetName = 'SpecificLog')]
        [String]
        $Name,

        # If specified, return only the default ScriptLog
        [Parameter(ParameterSetName = 'DefaultLog')]
        [switch]
        $Default
    )

    process {
        if ($Default) {
            if ($Script:ScriptLogs.Count -eq 0) {
                throw 'No ScriptLogs exists, cannot return default ScriptLog'
            }
            elseif (-not $DefaultScriptLog) {
                throw 'No default ScriptLog has been defined'
            }
            return $DefaultScriptLog
        }
        if ($Name) {
            $Log = $Script:ScriptLogs | Where-Object { $_.Name -eq $Name }
            if (-not $Log) {
                throw "Log with name '$Name' not found"
            }
            Return $Log
        }
        return $ScriptLogs
    }
}
