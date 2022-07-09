# Declare class for individual log messages
class LogMessage {
    [datetime]$DateTime
    [ScriptLogMessageSeverity]$Severity
    [string]$Source
    [string]$Context
    [int]$ProcessId
    [string]$Message

    LogMessage([datetime]$DateTime, [ScriptLogMessageSeverity]$Severity, [string]$Source, [string]$Context, [int]$ProcessId, [string]$Message) {
        $this.DateTime = $DateTime
        $this.Severity = $Severity
        $this.Source = $Source
        $this.Context = $Context
        $this.ProcessId = $ProcessId
        $this.Message = $Message
    }
}
