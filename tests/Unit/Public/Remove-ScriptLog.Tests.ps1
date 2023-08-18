Describe 'Remove-ScriptLog' {
    It 'should close the specific ScriptLog object requested (not default)' {
        Remove-ScriptLog -All
        $ScriptLog1 = New-ScriptLog -LogType Memory
        $ScriptLog2 = New-ScriptLog -LogType Memory
        $ScriptLog3 = New-ScriptLog -LogType Memory
        Out-ScriptLog -Message 'One' -Log $ScriptLog1
        Out-ScriptLog -Message 'One' -Log $ScriptLog2
        Out-ScriptLog -Message 'One' -Log $ScriptLog3
        Out-ScriptLog -Message 'Two' -Log $ScriptLog2
        Out-ScriptLog -Message 'Three' -Log $ScriptLog2
        Remove-ScriptLog -Log $ScriptLog2
        (Get-ScriptLog).Count | Should -Be 2
    }


    It 'should close all ScriptLog objects when return the All switch is used' {
        $ScriptLog1 = New-ScriptLog -LogType Memory
        $ScriptLog2 = New-ScriptLog -LogType Memory
        $ScriptLog3 = New-ScriptLog -LogType Memory
        Out-ScriptLog -Message 'One' -Log $ScriptLog1
        Out-ScriptLog -Message 'One' -Log $ScriptLog2
        Out-ScriptLog -Message 'One' -Log $ScriptLog3
        Out-ScriptLog -Message 'Two' -Log $ScriptLog1
        Out-ScriptLog -Message 'Three' -Log $ScriptLog1
        Remove-ScriptLog -All
        (Get-ScriptLog).Count | Should -Be 0
    }
    #TODO: Improve quality of tests and add additional tests to Remove-ScriptLog
}
