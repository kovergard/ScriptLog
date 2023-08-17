Describe 'Get-ScriptLog' {
    It 'should warn when requesting the default ScriptLog, if no default ScriptLog has been set' {
        Mock -CommandName Write-Warning -MockWith {}
        Get-ScriptLog -Default | Should -BeNullOrEmpty
    }
    It 'should return all ScriptLog objects, if no parameters are given.' {
        $ScriptLog1 = New-ScriptLog -LogType Memory
        $ScriptLog2 = New-ScriptLog -LogType Memory
        $AllScriptLogs = Get-ScriptLog
        $AllScriptLogs.Count | Should -Be 2
    }
    #TODO: Improve quality of tests and add additional tests to Get-ScriptLog
}
