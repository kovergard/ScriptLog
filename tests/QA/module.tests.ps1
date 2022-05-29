BeforeDiscovery {
    $ModuleName = 'ScriptLog'
}

BeforeAll {
    $ModuleName = 'ScriptLog'
    Import-Module $ModuleName
}

Describe "$ModuleName Sanity Tests - Help Content" -Tags 'Module' {
    BeforeDiscovery {
        # The module will need to be imported during Discovery since we're using it to generate test cases / Context blocks
        Import-Module $ModuleName

        $ShouldProcessParameters = 'WhatIf', 'Confirm'

        # Generate command list for generating Context / TestCases
        $Module = Get-Module $ModuleName
        $CommandList = @(
            $Module.ExportedFunctions.Keys
            $Module.ExportedCmdlets.Keys
        )
    }

    foreach ($Command in $CommandList)
    {
        Context "$Command - Help Content" {

            #region Discovery
            BeforeDiscovery {
                $Help = @{ Help = Get-Help -Name $Command -Full | Select-Object -Property * }
                $Parameters = Get-Help -Name $Command -Parameter * -ErrorAction Ignore |
                    Where-Object { $_.Name -and $_.Name -notin $ShouldProcessParameters } |
                        ForEach-Object {
                            @{
                                Name        = $_.name
                                Description = $_.Description.Text
                            }
                        }
                $Ast = @{
                    # Ast will be $null if the command is a compiled cmdlet
                    Ast        = (Get-Content -Path "function:/$Command" -ErrorAction Ignore).Ast
                    Parameters = $Parameters
                }
                $Examples = $Help.Help.Examples.Example | ForEach-Object { @{ Example = $_ } }
            }
            #endregion Discovery

            It "has help content for $Command" -TestCases $Help {
                $Help | Should -Not -BeNullOrEmpty
            }

            It "contains a synopsis for $Command" -TestCases $Help {
                $Help.Synopsis | Should -Not -BeNullOrEmpty
            }

            It "contains a description for $Command" -TestCases $Help {
                $Help.Description | Should -Not -BeNullOrEmpty
            }

            It "lists the function author in the Notes section for $Command" -TestCases $Help {
                $Notes = $Help.AlertSet.Alert.Text -split '\n'
                $Notes[0].Trim() | Should -BeLike 'Author: *'
            }

            # This will be skipped for compiled commands ($Ast.Ast will be $null)
            It "has a help entry for all parameters of $Command" -TestCases $Ast -Skip:(-not ($Parameters -and $Ast.Ast)) {
                @($Parameters).Count | Should -Be $Ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
            }

            It "has a description for $Command parameter -<Name>" -TestCases $Parameters -Skip:(-not $Parameters) {
                $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
            }

            It "has at least one usage example for $Command" -TestCases $Help {
                $Help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
            }

            It "lists a description for $Command example: <Title>" -TestCases $Examples {
                $Example.Remarks | Should -Not -BeNullOrEmpty -Because "example $($Example.Title) should have a description!"
            }
        }
    }
}

#TODO: Add additional QA module tests.

<#

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Convert-path required for PS7 or Join-Path fails
$ProjectPath = "$here\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
    ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
    $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch{$false}) }
).BaseName

$SourcePath = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch { $false }) }
    ).Directory.FullName

$mut = Import-Module -Name $ProjectName -ErrorAction Stop -PassThru -Force
$allModuleFunctions = &$mut {Get-Command -Module $args[0] -CommandType Function } $ProjectName

    Describe 'Changelog Management' -Tag 'Changelog' {
        It 'Changelog has been updated' -skip:(
            !([bool](Get-Command git -EA SilentlyContinue) -and
              [bool](&(Get-Process -id $PID).Path -NoProfile -Command 'git rev-parse --is-inside-work-tree 2>$null'))
            ) {
            # Get the list of changed files compared with master
            $HeadCommit = &git rev-parse HEAD
            $MasterCommit = &git rev-parse origin/main
            $filesChanged = &git @('diff', "$MasterCommit...$HeadCommit", '--name-only')

            if ($HeadCommit -ne $MasterCommit) { # if we're not testing same commit (i.e. master..master)
                $filesChanged.Where{ (Split-Path $_ -Leaf) -match '^changelog' } | Should -Not -BeNullOrEmpty
            }
        }

        It 'Changelog format compliant with keepachangelog format' -skip:(![bool](Get-Command git -EA SilentlyContinue)) {
            { Get-ChangelogData (Join-Path $ProjectPath 'CHANGELOG.md') -ErrorAction Stop } | Should -Not -Throw
        }
    }

    Describe 'General module control' -Tags 'FunctionalQuality' {

        It 'imports without errors' {
            { Import-Module -Name $ProjectName -Force -ErrorAction Stop } | Should -Not -Throw
            Get-Module $ProjectName | Should -Not -BeNullOrEmpty
        }

        It 'Removes without error' {
            { Remove-Module -Name $ProjectName -ErrorAction Stop } | Should -not -Throw
            Get-Module $ProjectName | Should -beNullOrEmpty
        }
    }

    if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule
    }
    else {
        if ($ErrorActionPreference -ne 'Stop') {
            Write-Warning "ScriptAnalyzer not found!"
        }
        else {
            Throw "ScriptAnalyzer not found!"
        }
    }

    foreach ($function in $allModuleFunctions) {
        $functionFile = Get-ChildItem -path $SourcePath -Recurse -Include "$($function.Name).ps1"
        Describe "Quality for $($function.Name)" -Tags 'TestQuality' {
            It "$($function.Name) has a unit test" {
                Get-ChildItem "tests\" -recurse -include "$($function.Name).Tests.ps1" | Should -Not -BeNullOrEmpty
            }

            if ($scriptAnalyzerRules) {
                It "Script Analyzer for $($functionFile.FullName)" {
                    $PSSAResult = (Invoke-ScriptAnalyzer -Path $functionFile.FullName)
                    $Report = $PSSAResult | Format-Table -AutoSize | Out-String -Width 110
                    $PSSAResult  | Should -BeNullOrEmpty -Because `
                        "some rule triggered.`r`n`r`n $Report"
                }

            }
        }

        Describe "Help for $($function.Name)" -Tags 'helpQuality' {
            $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::
            ParseInput((Get-Content -raw $functionFile.FullName), [ref]$null, [ref]$null)
            $AstSearchDelegate = { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }
            $ParsedFunction = $AbstractSyntaxTree.FindAll( $AstSearchDelegate, $true ) |
                ? Name -eq $function.Name

            $FunctionHelp = $ParsedFunction.GetHelpContent()

            It 'Has a SYNOPSIS' {
                $FunctionHelp.Synopsis | should not BeNullOrEmpty
            }

            It 'Has a Description, with length > 40' {
                $FunctionHelp.Description.Length | Should beGreaterThan 40
            }

            It 'Has at least 1 example' {
                $FunctionHelp.Examples.Count | Should beGreaterThan 0
                $FunctionHelp.Examples[0] | Should match ([regex]::Escape($function.Name))
                $FunctionHelp.Examples[0].Length | Should BeGreaterThan ($function.Name.Length + 10)
            }

            $parameters = $ParsedFunction.Body.ParamBlock.Parameters.name.VariablePath.Foreach{ $_.ToString() }
            foreach ($parameter in $parameters) {
                It "Has help for Parameter: $parameter" {
                    $FunctionHelp.Parameters.($parameter.ToUpper()) | Should Not BeNullOrEmpty
                    $FunctionHelp.Parameters.($parameter.ToUpper()).Length | Should BeGreaterThan 25
                }
            }
        }
    }

    #>
