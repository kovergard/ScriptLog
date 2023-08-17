Describe 'New-ScriptLog' {
    It 'should return a ScriptLog object with default properties when no parameters are given' {
        $ScriptLog = New-ScriptLog
        $ScriptLog.GetType().Name | Should -Be 'ScriptLog'
        $ScriptLog.LogType | Should -Be 'CMTrace'
        $ScriptLog.MessagesOnConsole | Should -Be @('Error', 'Warning')
    }
    It 'should return a ScriptLog object that matches the given parameters, when all parameters are set to non-default value' {
        $ScriptLog = New-ScriptLog -Path $PSScriptRoot -BaseName 'CustomLog' -LogType Memory -MessagesOnConsole @('Information', 'Verbose')
        $ScriptLog.GetType().Name | Should -Be 'ScriptLog'
        $ScriptLog.LogType | Should -Be 'Memory'
        $ScriptLog.MessagesOnConsole | Should -Be @('Information', 'Verbose')
    }
    It 'should return a ScriptLog object where the outfile name have a datetime suffixed, if AppendDateTime is set to true' {
        $ScriptLog = New-ScriptLog -AppendDateTime
        $ScriptLog.GetType().Name | Should -Be 'ScriptLog'
        $ScriptLog.FilePath -match 'ScriptLog-\d{14}\.log$' | Should -Be $true
    }
    It 'should throw an error if two ScriptLog objects are using the same filepath' {
        { 
            $ScriptLog1 = New-ScriptLog
            $ScriptLog2 = New-ScriptLog 
        } | Should -Throw
    }
}
