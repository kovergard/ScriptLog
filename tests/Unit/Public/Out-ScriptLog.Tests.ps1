BeforeDiscovery {
    $ModuleName = 'ScriptLog'
}

BeforeAll {
    $ModuleName = 'ScriptLog'
    Import-Module $ModuleName -Force
}

Describe 'Out-ScriptLog' {

    It 'should throw an error if trying to send a message if no ScriptLog has been defined' {
        { 'Test' | Out-ScriptLog } | Should -Throw 'Use New-ScriptLog to create a ScriptLog before using Out-ScriptLog'
    }

    It 'must have a message count of 1 after adding a single message' {
        $ScriptLog = New-ScriptLog
        'Test' | Out-ScriptLog -Log $ScriptLog
        $ScriptLog.Messages.Count | Should -Be 1
    }

    It 'should output messages with severity Information using Write-Information' {
        $ScriptLog = New-ScriptLog -MessagesOnConsole Information
        Mock -ModuleName $ModuleName -CommandName 'Write-Information' -MockWith { return 'Test.Information' } -ParameterFilter { $MessageData -eq 'Test.Information' }
        Out-ScriptLog -Message 'Test.Information' -Log $ScriptLog -Severity Information -InformationAction Continue | Should -Be 'Test.Information'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Information' -Exactly 1 -Scope it
    }

    It 'should output messages with severity Verbose using Write-Verbose' {
        $ScriptLog = New-ScriptLog -MessagesOnConsole Verbose
        Mock -ModuleName $ModuleName -CommandName 'Write-Verbose' -MockWith { return 'Test.Verbose' } -ParameterFilter { $Message -eq 'Test.Verbose' }
        Out-ScriptLog -Message 'Test.Verbose' -Log $ScriptLog -Severity Verbose | Should -Be 'Test.Verbose'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Verbose' -Exactly 1 -Scope it
    }

    It 'should output messages with severity Warning using Write-Warning' {
        $ScriptLog = New-ScriptLog
        Mock -ModuleName $ModuleName -CommandName 'Write-Warning' -MockWith { return 'Test.Warning' } -ParameterFilter { $Message -eq 'Test.Warning' }
        Out-ScriptLog -Message 'Test.Warning' -Log $ScriptLog -Severity Warning | Should -Be 'Test.Warning'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Warning' -Exactly 1 -Scope it
    }

    It 'should output messages with severity Error using Write-Error' {
        $ScriptLog = New-ScriptLog
        Mock -ModuleName $ModuleName -CommandName 'Write-Error' -MockWith { return 'Test.Error' } -ParameterFilter { $Message -eq 'Test.Error' }
        Out-ScriptLog -Message 'Test.Error' -Log $ScriptLog -Severity Error | Should -Be 'Test.Error'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Error' -Exactly 1 -Scope it
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
