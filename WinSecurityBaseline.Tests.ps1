param(
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion
)


$Choco = choco --version
if (!$Choco) {
    Write-Host "Choco not installed - Installing..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
elseif ($Choco -lt '2.0.0') {
    choco upgrade chocolatey
}

$WorkingFiles = Get-ChildItem -Recurse
Write-Host $WorkingFiles
Write-Host $PackageName
$Nupkg = $WorkingFiles | Where-Object {($_.Extension -eq '.nupkg') -and ($_.Name -match "$PackageName")}
Write-Host $Nupkg

<#Debug Tesging
$NupkgOutput = choco install $Nupkg.FullName -y
Write-Host $NupkgOutput
$ChocoLogs = Get-Content -Path "$($env:programdata)\chocolatey\logs\chocolatey.log"
Write-Host $ChocoLogs
#>

Describe 'Chocolatey Packages Install' {
    It "Install: $PackageName" -TestCases @{PackageName = $PackageName; PackageVersion = $PackageVersion; Nupkg = $Nupkg}  {
        $PkgInstall = $null
        $PkgInstall = choco install $PackageName --version="$PackageVersion" --source="$PSScriptRoot"
        #Write-Host $PkgInstall
        #Write-Host $PSScriptRoo
        $PkgInstall | Where-Object {$_ -match "The install of $PackageName was successful"} | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package is listed' {
    It "Listed" -TestCases @{PackageName = $PackageName} {
        $PkgList = $null
        $PkgList = choco list
        $PkgList | Where-Object {$_ -match $PackageName} | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package Contents exist' {
    It "$PackageName" -TestCases @{PackageName = $PackageName} {
        $PkgContents = $null
        $PkgContents = Get-ChildItem -Path "${env:ProgramFiles(x86)}\$PackageName" -Recurse
        $PkgContents | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package Uninstall' {
    It "Uninstall: $PackageName" -TestCases @{PackageName = $PackageName} {
        $PkgUninstall = $null
        $PkgUninstall = choco uninstall $PackageName -y
        $PkgUninstall | Where-Object {$_ -match "$PackageName has been successfully uninstalled"} | Should -Not -Be $null
    }
}
