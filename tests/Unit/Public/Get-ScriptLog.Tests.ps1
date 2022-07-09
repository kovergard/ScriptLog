Describe 'Get-ScriptLog' {
    It 'Requesting the default ScriptLog should fail if no default ScriptLog has been set' {
        Mock -CommandName Write-Warning -MockWith {}
        Get-ScriptLog -Default | Should -BeNullOrEmpty
    }
    It 'Given no parameters, it should return all ScriptLog objects' {
        $ScriptLog1 = New-ScriptLog
        $ScriptLog2 = New-ScriptLog
        $AllScriptLogs = Get-ScriptLog
        $AllScriptLogs.Count | Should -Be 2
    }
    #TODO: Improve quality of tests and add additional tests to Get-ScriptLog
}
