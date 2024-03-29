param(
    [Parameter(Mandatory = $true)]
    [string]$OutputFormat = 'JUnitXml'
)

Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name Pester -MinimumVersion 5.2.2 -Confirm:$false -Force

$outputFile = "$PSScriptRoot\Pester-Tests.xml"

$pesterConfigurationContainer = New-PesterContainer -Path "WinSecurityBaseline.Tests.ps1" -Data @{PackageName = 'WinSecurityBaseline'}

$pesterConfiguration = [PesterConfiguration]::Default
$pesterConfiguration.Run.Container = $pesterConfigurationContainer
$pesterConfiguration.Run.PassThru = $true
$pesterConfiguration.TestResult.Enabled = $true
$pesterConfiguration.TestResult.OutputPath = $outputFile
$pesterConfiguration.TestResult.OutputFormat = $outputFormat
$pesterConfiguration.Output.Verbosity = "Detailed"
#$pesterConfiguration.Debug.WriteDebugMessages = $true

$pesterResult = Invoke-Pester -Configuration $pesterConfiguration

Write-Host "Failed Test Output:"
$pesterResult.failed.StandardOutput

if ($pesterResult.FailedCount -gt 0) { 
    throw "$($pesterResult.FailedCount) Tests Failed."
}