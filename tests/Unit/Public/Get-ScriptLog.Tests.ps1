Describe 'Get-ScriptLog' {

    BeforeEach {
        Remove-ScriptLog -All
    }

    It 'should return nothing when no logs has been defined' {
        $NoLogs = Get-ScriptLog
        $NoLogs.Count | Should -Be 0
    }

    It 'should return the default ScriptLog object when requested' {
        New-ScriptLog -Name 'DefaultLog' -LogType Memory
        New-ScriptLog -Name 'AnotherLog' -LogType Memory
        (Get-ScriptLog -Default).Name | Should -Be 'DefaultLog'
    }

    It 'should return a specific ScriptLog, if requested by name' {
        New-ScriptLog -Name 'Log1' -LogType Memory
        New-ScriptLog -Name 'Log2' -LogType Memory
        New-ScriptLog -Name 'Log3' -LogType Memory
        (Get-ScriptLog -Name 'Log2').Name | Should -Be 'Log2'
    }

    It 'should return all ScriptLog objects, if no parameters are given' {
        New-ScriptLog -Name 'Log1' -LogType Memory
        New-ScriptLog -Name 'Log2' -LogType Memory
        New-ScriptLog -Name 'Log3' -LogType Memory
        $AllScriptLogs = Get-ScriptLog
        $AllScriptLogs.Count | Should -Be 3
    }

    It 'should throw when requesting a ScriptLog that doesnt exist by name' {
        { Get-ScriptLog -Name 'DoesNotExist' } | Should -Throw "Log with name 'DoesNotExist' not found"
    }

    It 'should throw when requesting the default ScriptLog if no logs has been created yet' {
        { Get-ScriptLog -Default } | Should -Throw 'No ScriptLogs exists, cannot return default ScriptLog'
    }

    It 'should throw when requesting the default ScriptLog if there is no default' {
        New-ScriptLog -Name 'DefaultToDelete' -LogType Memory
        New-ScriptLog -Name 'ExtraToKeep' -LogType Memory
        Remove-ScriptLog -Name 'DefaultToDelete'
        { Get-ScriptLog -Default } | Should -Throw 'No default ScriptLog has been defined'
    }


    <#    It 'should warn when requesting the default ScriptLog if no logs has been created yet' {
        Mock -ModuleName 'ScriptLog' -CommandName Write-Warning -MockWith { Return 'WarningNoLogs' } -ParameterFilter { $Message -eq 'No ScriptLogs exists, cannot return default ScriptLog' }
        $DefaultLog = Get-ScriptLog -Default 
        $DefaultLog | Should -Be 'WarningNoLogs'
    }

    It 'should warn when requesting the default ScriptLog if there is no default' {
        New-ScriptLog -Name 'DefaultToDelete' -LogType Memory
        New-ScriptLog -Name 'ExtraToKeep' -LogType Memory
        Remove-ScriptLog -Name 'DefaultToDelete'
        Mock -ModuleName 'ScriptLog' -CommandName Write-Warning -MockWith { Return 'WarningNoDefaultLog' } -ParameterFilter { $Message -eq 'No default ScriptLog has been defined' }
        $DefaultLog = Get-ScriptLog -Default 
        $DefaultLog | Should -Be 'WarningNoDefaultLog'
    }
#>

    #TODO: Improve quality of tests and add additional tests to Get-ScriptLog
}
