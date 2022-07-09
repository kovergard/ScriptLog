Describe 'New-ScriptLog' {
    It 'Given no parameters, it should return a ScriptLog object with default properties' {
        $ScriptLog = New-ScriptLog
        $ScriptLog.GetType().Name | Should -Be 'ScriptLog'
    }
    It 'Given all parameters set to non-default value, it should return a ScriptLog object that matches the parameters set' {
        $ScriptLog = New-ScriptLog -Path $PSScriptRoot -BaseName 'CustomLog' -LogType Memory -MessagesOnConsole @('Information', 'Verbose')
        $ScriptLog.GetType().Name | Should -Be 'ScriptLog'
    }
    It 'Given the AppendDateTime parameter, it should return a ScriptLog object where the outfile name have a datetime suffixed' {
        $ScriptLog = New-ScriptLog -AppendDateTime $true
        $ScriptLog.GetType().Name | Should -Be 'ScriptLog'
    }
    #TODO: Improve quality of tests and add additional tests to New-ScriptLog
}
