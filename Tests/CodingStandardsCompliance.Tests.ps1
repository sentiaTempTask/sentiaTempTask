
$path = Split-Path -parent $PSCommandPath
$path = Split-Path -Path $path -parent
$path += '\*'
$scriptsModules = Get-ChildItem -Path $path -Include *.psd1, *.psm1, *Omada*.ps1 -Exclude *.tests.ps1



Describe 'General' -Tag "Compliance" {
   Context 'Checking files' {
       It 'Checking files exist to test.' {
           $scriptsModules.count | Should Not Be 0
       }
       It 'Checking Invoke-ScriptAnalyzer exists.' {
           { Get-Command Invoke-ScriptAnalyzer -ErrorAction Stop } | Should Not Throw
       }
   }

   $scriptAnalyzerRules = Get-ScriptAnalyzerRule

   $arraySkipTest = @(
                    "PSUseOutputTypeCorrectly"
                    )

   forEach ($scriptModule in $scriptsModules) {
       switch -wildCard ($scriptModule) { 
           '*.psm1' { $typeTesting = 'Module' } 
           '*.ps1'  { $typeTesting = 'Script' } 
           '*.psd1' { $typeTesting = 'Manifest' } 
       }

       Context ('Checking {0} - {1}' -f $typeTesting, ($scriptModule.FullName.Split('\')[-1])) {
           forEach ($scriptAnalyzerRule in $scriptAnalyzerRules) {
              if ($arraySkipTest -notcontains $scriptAnalyzerRule){
                   It (' Rule {0} - {1}' -f $scriptAnalyzerRule, ($scriptModule.FullName.Split('\')[-1])) {
                    (Invoke-ScriptAnalyzer -Path $scriptModule -IncludeRule $scriptAnalyzerRule).count | Should Be 0
                   }
               }
           }
       }
   }
}