# Force import of local build module, remove if you have installed the ScriptLog module from PSGallery
Import-Module $PSScriptRoot\..\output\ScriptLog\0.1.0\ScriptLog.psm1 -Force

# Add a new default log
Remove-ScriptLog -All
New-ScriptLog -Name 'CMTraceExample' -BaseName 'ScriptLog-Example-CMTrace' -LogType CMTrace

# Log that script is starting
Out-ScriptLog -Message 'Starting script execution'

# Write some test to channels
Out-ScriptLog -Message 'This is an error message' -Severity Error
Out-ScriptLog -Message 'This is an warning message' -Severity Warning
Out-ScriptLog -Message 'This is an verbose message' -Severity Verbose
Out-ScriptLog -Message 'This is an information message' -Severity Information

# Send multiple messages using the pipeline. Each message will get its own log message.
'One', 'Two', 'Three' | Out-ScriptLog 

# Send an object with multiple lines to the log file. This will be writtin as a single log message, since the message is not passed through the pipeline.
$AllProcesses = Get-Process
Out-ScriptLog -Message $AllProcesses

# Log that script completed
Out-ScriptLog -Message 'Script execution completed'
