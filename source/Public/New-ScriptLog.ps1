function New-ScriptLog {
    <#
        .SYNOPSIS
            Returns a new ScriptLog object

        .DESCRIPTION
            Creates a new ScriptLog object with the settings provided and returns it through the pipeline so it can be used for logging during script execution using the Out-ScriptLog cmdlet.

        .EXAMPLE
            New-ScriptLog

            Create a new ScriptLog object with default settings. File will be created in the temp folder, with the name ScriptLog.log and will be written in the CMTrace format.

        .EXAMPLE
            $MemoryLog = New-ScriptLog -LogType Memory -MessagesOnConsole @("Error","Verbose")

            Create an in-memory SriptLog instance to allow for collection of log messages during runtime. Only errors and verbose messages will be written to the console (Warnings will not, they will only be written to the in-memory log)

        .EXAMPLE
            $CriticalFileLog = New-ScriptLog -Path "C:\Logs" -BaseName "CriticalErrors" -AppendDateTime; $VerboseLog = New-ScriptLog -Path "C:\Logs" -BaseName "Verbose" -MessagesOnConsole "Verbose"

            Create two separate ScriptLog objects to log messages in different formats to two different files.

        .NOTES
            Author: kovergard
    #>
    [CmdletBinding()]
    [OutputType([ScriptLog])]
    Param (
        # Directory in which to create the logfile
        [Parameter()]
        [string]
        $Path = $env:TEMP,

        # Name of the log file without extension
        [Parameter()]
        [string]
        $BaseName = 'ScriptLog',

        # Indicates if a datetime should be suffixed on the log base name.
        [Parameter()]
        [bool]
        $AppendDateTime = $false,

        # Type of log
        [Parameter()]
        [ScriptLogType]
        $LogType = 'CMTrace',

        # Determines which messages (if any) should be written to the console.
        [Parameter()]
        [ScriptLogMessageSeverity[]]
        $MessagesOnConsole = @('Error', 'Warning')
    )

    process {
        $NewScriptLog = [ScriptLog]::New($Path, $BaseName, $AppendDateTime, $LogType, $MessagesOnConsole)
        $Script:ScriptLogs.Add($NewScriptLog)
        if (-not $DefaultScriptLog) {
            Set-Variable -Name DefaultScriptLog -Value $NewScriptLog -Scope Script -Force
        }
        Write-Output $NewScriptLog
    }
}
