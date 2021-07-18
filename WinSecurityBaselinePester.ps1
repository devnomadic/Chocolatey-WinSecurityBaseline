
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name Pester -MinimumVersion 5.2.2 -Confirm:$false -Force

$outputFile = "$PSScriptRoot\Test-Pester.XML"
$pesterConfigurationContainer = New-PesterContainer -Path "WinSecurityBaseline.Tests.ps1" -Data @{PackageName = 'WinSecurityBaseline'}

$pesterConfiguration = [PesterConfiguration]::Default
$pesterConfiguration.Run.Container = $pesterConfigurationContainer
$pesterConfiguration.Run.PassThru = $true
$pesterConfiguration.TestResult.Enabled = $true
$pesterConfiguration.TestResult.OutputPath = $outputFile
$pesterConfiguration.Output.Verbosity = "Detailed"
#$pesterConfiguration.Debug.WriteDebugMessages = $true

$pesterResult = Invoke-Pester -Configuration $pesterConfiguration

Write-Host "Failed Test Output:"
$pesterResult.failed.StandardOutput