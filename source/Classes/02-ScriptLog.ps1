# Declare class for a log object
class ScriptLog {
    [String] $FilePath
    [ScriptLogType] $LogType
    [String] $Source = $null
    [ScriptLogMessageSeverity[]] $MessagesOnConsole
    [DateTime] $StartTimeStamp
    [System.Collections.Generic.List[LogMessage]] $Messages
    hidden [String] $TimeZoneOffset

    ScriptLog([String] $Path, [String] $BaseName, [Boolean] $AppendDateTime, [ScriptLogType] $LogType, [ScriptLogMessageSeverity[]] $MessagesOnConsole) {
        $this.LogType = $LogType
        $this.MessagesOnConsole = $MessagesOnConsole
        $this.StartTimeStamp = Get-Date
        $this.Messages = [System.Collections.Generic.List[LogMessage]]::new()
        $Offset = [timezone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes
        if ($Offset -ge 0) {
            $this.TimeZoneOffset = "+$Offset"
        }
        else {
            $this.TimeZoneOffset = [string]"$Offset"
        }
        if ($LogType -eq 'Memory') {
            $this.FilePath = $null
        }
        else {
            $ConstructedPath = $Path + '\' + $BaseName
            if ($AppendDateTime) {
                $ConstructedPath += '-' + (Get-Date -Format 'yyyyMMddHHmmss')
            }
            switch ($LogType) {
                CMTrace {
                    $ConstructedPath += '.log'
                }
            }
            # Ensure path is not already used by another ScriptLog
            if ($Script:ScriptLogs.count -gt 0) {
                if ($ConstructedPath -in $Script:ScriptLogs.FilePath) {
                    throw "Another active ScriptLog is already using the file '$ConstructedPath'"
                }
            }
            $this.FilePath = $ConstructedPath
        }
    }
}
