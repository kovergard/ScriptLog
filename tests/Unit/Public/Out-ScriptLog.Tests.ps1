Describe 'Out-ScriptLog' {

    BeforeEach {
        $ModuleName = 'ScriptLog'
        Remove-ScriptLog -All
    }

    It 'should throw an error if trying to send a message if no ScriptLog has been defined' {
        { 'Test' | Out-ScriptLog } | Should -Throw 'No default ScriptLog has been defined, please use -Name or -Log parameter to target log'
    }

    It 'must have a message count of 1 after adding a single message' {
        $ScriptLog = New-ScriptLog -LogType Memory
        'Test' | Out-ScriptLog -Log $ScriptLog
        $ScriptLog.Messages.Count | Should -Be 1
    }

    It 'should have a one of each message severity in memory.' {
        New-ScriptLog -Name 'SeverityTests' -AppendDateTime -MessagesOnConsole @()
        'Information', 'Verbose', 'Warning', 'Error' | ForEach-Object { $_ | Out-ScriptLog -Severity $_ }
        $ScriptLog = Get-ScriptLog -Name 'SeverityTests'
        ($ScriptLog.Messages | Where-Object { $_.Severity -eq 'Information' }).Count | Should -Be 1
        ($ScriptLog.Messages | Where-Object { $_.Severity -eq 'Verbose' }).Count | Should -Be 1
        ($ScriptLog.Messages | Where-Object { $_.Severity -eq 'Warning' }).Count | Should -Be 1
        ($ScriptLog.Messages | Where-Object { $_.Severity -eq 'Error' }).Count | Should -Be 1
    }

    It 'shold throw if trying to log to a named ScriptLog which doesnt exist' {
        { 'Test' | Out-ScriptLog -Name 'DoesNotExist' } | Should -Throw "Log with name 'DoesNotExist' not found"
    }

    It 'should output messages with severity Information using Write-Information' {
        New-ScriptLog -Name 'InformationTest' -LogType Memory -MessagesOnConsole Information
        Mock -ModuleName $ModuleName -CommandName 'Write-Information' -MockWith { Write-Output 'Test.Information' } -ParameterFilter { $MessageData -eq 'Test.Information' }
        Out-ScriptLog -Message 'Test.Information' -Name 'InformationTest' -Severity Information -InformationAction Continue | Should -Be 'Test.Information'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Information' -Exactly 1 -Scope it
    }
    
    It 'should output messages with severity Verbose using Write-Verbose' {
        New-ScriptLog -Name 'VerboseTest' -LogType Memory -MessagesOnConsole Verbose
        Mock -ModuleName $ModuleName -CommandName 'Write-Verbose' -MockWith { Write-Output 'Test.Verbose' } -ParameterFilter { $Message -eq 'Test.Verbose' }
        Out-ScriptLog -Message 'Test.Verbose' -Name 'VerboseTest' -Severity Verbose | Should -Be 'Test.Verbose'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Verbose' -Exactly 1 -Scope it
    }
    
    It 'should output messages with severity Warning using Write-Warning' {
        New-ScriptLog -Name 'WarningTest' -LogType Memory
        Mock -ModuleName $ModuleName -CommandName 'Write-Warning' -MockWith { Write-Output 'Test.Warning' } -ParameterFilter { $Message -eq 'Test.Warning' }
        Out-ScriptLog -Message 'Test.Warning' -Name 'WarningTest' -Severity Warning | Should -Be 'Test.Warning'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Warning' -Exactly 1 -Scope it
    }

    It 'should output messages with severity Error using Write-Error' {
        $ScriptLog = New-ScriptLog -Name 'ErrorTest' -LogType Memory
        Mock -ModuleName $ModuleName -CommandName 'Write-Error' -MockWith { Write-Output 'Test.Error' } -ParameterFilter { $Message -eq 'Test.Error' }
        Out-ScriptLog -Message 'Test.Error' -Name 'ErrorTest' -Severity Error | Should -Be 'Test.Error'
        Assert-MockCalled -ModuleName $ModuleName -CommandName 'Write-Error' -Exactly 1 -Scope it
    }
    #>
    It 'should truncate long messages in CMTrace format.' {
        $ScriptLog = New-ScriptLog -LogType CMTrace -BaseName 'Out-ScriptLog.Test.Truncated' -AppendDateTime 
        Get-Process | Out-String | Out-ScriptLog -Log $ScriptLog
        try {
            $LogFileContent = Get-Content -Path $ScriptLog.FilePath
            $LogMessageLength = ([regex]::match($LogFileContent, 'LOG\[([\s\S]*?)\]LOG').Groups[1].Value).Length
        }
        catch {
            $LogMessageLength = 0
        }
        $LogMessageLength | Should -BeLessThan 7500
    }

    It 'should respect if a custom source has been set.' {
        $CustomSourceName = 'Mycustomsource'
        $ScriptLog = New-ScriptLog -LogType Memory
        $ScriptLog.Source = $CustomSourceName
        'Test custom source' | Out-ScriptLog -Log $ScriptLog
        $SourceNameInLog = $ScriptLog.Messages[0].Source.Split(':')[0]
        $SourceNameInLog | Should -Be $CustomSourceName
    }

    #TODO: Improve quality of tests and add additional tests to Out-ScriptLog
}
