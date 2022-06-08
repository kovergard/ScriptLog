Describe 'Out-ScriptLog' {
    # The following cannot be tested before a function has been added to purge all ScriptLogs objects.
    <#
        It 'Trying to send a message to a ScriptLog should fail if no ScriptLog objects has been instantiated' {
        { 'Test' | Out-ScriptLog } | Should -Throw
    } #>
    It 'must have a message count of 1 after adding a single message' {
        $ScriptLog = New-ScriptLog
        'Test' | Out-ScriptLog -Log $ScriptLog
        $ScriptLog.Messages.Count | Should -Be 1
    }

    It 'should output different severities to the respective channels.' {
        $ScriptLog = New-ScriptLog
        Out-ScriptLog -Message 'Information' -Log $ScriptLog -Severity Information
        Out-ScriptLog -Message 'Verbose' -Log $ScriptLog -Severity Verbose -Verbose
        Out-ScriptLog -Message 'Warning' -Log $ScriptLog -Severity Warning
        Out-ScriptLog -Message 'Error' -Log $ScriptLog -Severity Error
    }

    It 'should truncate long messages in CMTrace format.' {
        $ScriptLog = New-ScriptLog -LogType CMTrace
        Get-Process | Out-String | Out-ScriptLog -Log $ScriptLog
    }

    It 'should respect if a custom source has been set.' {
        $ScriptLog = New-ScriptLog -LogType Memory
        $ScriptLog.Source = 'Mycustomsource'
        'Test custom source' | Out-ScriptLog -Log $ScriptLog
    }

    #TODO: Improve quality of tests and add additional tests to Out-ScriptLog
}
