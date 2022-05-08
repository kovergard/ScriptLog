#$PSDefaultParameterValues.Clear()
#Set-StrictMode -Version 3

# Prepare value defining the default ScriptLog to log messages to
$DefaultScriptLog = $null

# Prepare collection to hold ScriptLog objects
[System.Collections.Generic.List[ScriptLog]]$ScriptLogs = @()
