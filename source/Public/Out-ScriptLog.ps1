function Out-ScriptLog {

    <#
        .SYNOPSIS
            Adds log messages to a ScriptLog.

        .DESCRIPTION
            Adds one or more log messages to a ScriptLog object. If multiple messages are sent via the pipleline, each message will get its own message entry in the log.

            A single messages can have multiple lines, these will be writting to the log file with line changes. If a message is longer than 7500 characters, it will be broken into multiple messages as longer messages will break the CMTrace format.

        .EXAMPLE
            Out-ScriptLog -Message "Starting script execution"

            Write a log message to the information channel in the default ScriptLog instance.

        .EXAMPLE
            Out-ScriptLog -Log $VerboseLog -Message "Starting script execution" -Severity Verbose

            Write a log message to the verbose channel in the ScriptLog $VerboseLog

        .EXAMPLE
            $Dir = Get-ChildItem -Path c:\temp; Out-ScriptLog -Message $Dir -Log $Log

            Write an object with multiple lines in it to the log file. This will be writtin as a single log message, since the message is not passed through the pipeline.

        .EXAMPLE
            "One","Two","Three" | Out-ScriptLog -Severity Warning

            Send multiple messages to the log using the pipeline. Each message will get its own log message.

        .NOTES
            Author: kovergard
    #>
    [CmdletBinding()]
    Param (
        # One or more messages to add to the log
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        $Message,

        # The ScriptLog object to add the messages to. If no ScriptLog is supplied, logging is done to the default ScriptLog.
        [Parameter()]
        [ScriptLog]
        $Log,

        # The severity of the messages
        [Parameter()]
        [ScriptLogMessageSeverity]
        $Severity = 'Information'
    )

    process {
        # Fail if no ScriptLogs exists
        if ($ScriptLogs.Count -eq 0) {
            throw 'Use New-ScriptLog to create a ScriptLog before using Out-ScriptLog'
        }

        # If no ScriptLog is specified, point to default ScriptLog.
        if (-not $PSBoundParameters.ContainsKey('Log')) {
            $Log = $DefaultScriptLog
        }

        # Convert message to string if necessary
        if ($Message.GetType() -ne 'System.String') {
            $Message = ($Message | Out-String).TrimEnd("`r`n")
        }

        # Determine log time and source of message
        $LogTime = Get-Date
        if ($Log.Source) {
            $Source = $Log.Source
            if ($MyInvocation.ScriptLineNumber) {
                $Source += ":$($MyInvocation.ScriptLineNumber)"
            }
        }
        else {
            Try {
                If ($MyInvocation.ScriptName) {
                    [string]$Source = "$(Split-Path -Path $MyInvocation.ScriptName -Leaf -ErrorAction 'Stop'):$($MyInvocation.ScriptLineNumber)"
                }
                Else {
                    $Source = 'interactive'
                }
            }
            Catch {
                $Source = 'unknown'
            }
        }

        # Get context and PID of message
        $Context = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $ProcessId = $global:PID

        # Add message to in-memory log.
        $Log.Messages.Add([LogMessage]::New($LogTime, $Severity, $Source, $Context, $ProcessId, $Message))

        # If message should be written to a file, convert to proper format and write.
        switch ($Log.LogType) {
            CMTrace {
                if ($Message.Length -gt 7500) {
                    $CMMessage = $Message.Substring(0, 7500)
                }
                else {
                    $CMMessage = $Message
                }
                $CmLogLine = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="{6}" file="{7}">'
                $CmMessageType = Switch ($Severity) {
                    Error { 3 }
                    Warning { 2 }
                    Default { 1 }
                }
                $CmTime = ($LogTime | Get-Date -Format 'HH\:mm\:ss.fff').ToString() + $Log.TimeZoneOffset
                $CmDate = ($LogTime | Get-Date -Format 'MM-dd-yyyy')
                $CmFile = 'ScriptLog'
                $CmLogLineFormat = $CMMessage, $CmTime, $CmDate, $Source, $Context, $CmMessageType, $ProcessId, $CmFile
                $LogLine = $CmLogLine -f $CmLogLineFormat
                $LogLine | Out-File -FilePath $Log.FilePath -Append -Encoding utf8 -NoClobber
            }
        }

        # Write output to console, if applicable
        if ($Severity -in $Log.MessagesOnConsole) {
            Switch ($Severity) {
                Information {
                    Write-Information -MessageData $Message -InformationAction Continue
                }
                Verbose {
                    $VerbosePreference = 'Continue'; Write-Verbose -Message $Message
                }
                Warning {
                    Write-Warning -Message $Message
                }
                Error {
                    Write-Error -Message $Message
                }
            }
        }
    }
}
