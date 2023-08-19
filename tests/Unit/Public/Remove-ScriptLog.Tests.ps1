Describe 'Remove-ScriptLog' {

    BeforeEach {
        Remove-ScriptLog -All
    }

    It 'should close the specific ScriptLog object requested (not default)' {
        New-ScriptLog -Name 'Log1' -LogType Memory
        New-ScriptLog -Name 'Log2' -LogType Memory
        New-ScriptLog -Name 'Log3' -LogType Memory
        Remove-ScriptLog -Name 'Log2'
        (Get-ScriptLog).Count | Should -Be 2
    }

    It 'should close all ScriptLog objects when return the All switch is used' {
        New-ScriptLog -Name 'Log1' -LogType Memory | Out-Null
        New-ScriptLog -Name 'Log2' -LogType Memory | Out-Null
        New-ScriptLog -Name 'Log3' -LogType Memory | Out-Null
        Remove-ScriptLog -All
        (Get-ScriptLog).Count | Should -Be 0
    }

    It 'should throw if asked to remove a ScriptLog that doesnt exist. ' {
        { Remove-ScriptLog -Name 'DoesNotExist' } | Should -Throw "Log with name 'DoesNotExist' not found"
    }

    #TODO: Improve quality of tests and add additional tests to Remove-ScriptLog
}
