param(
    [Parameter(Mandatory = $false)]
    [string]$PackageName = 'WinSecurityBaseline'
)

if (!(choco --version))
{
    Write-Host "Choco not installed - Installing..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
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
    It "Install: $PackageName" {
        $PkgInstall = $null
        $PkgInstall = choco install $Nupkg.FullName -y
        $PkgInstall | Where-Object {$_ -match "The install of $PackageName was successful"} | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package is listed' {
    It "Listed" {
        $PkgList = $null
        $PkgList = choco list --local-only
        $PkgList | Where-Object {$_ -match $PackageName} | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package Contents exist' {
    It "$PackageName" {
        $PkgContents = $null
        $PkgContents = Get-ChildItem -Path "${env:ProgramFiles(x86)}\$PackageName" -Recurse
        $PkgContents | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package Uninstall' {
    It "Uninstall: $PackageName" {
        $PkgUninstall = $null
        $PkgUninstall = choco uninstall $PackageName -y
        $PkgUninstall | Where-Object {$_ -match "$PackageName has been successfully uninstalled"} | Should -Not -Be $null
    }
}
