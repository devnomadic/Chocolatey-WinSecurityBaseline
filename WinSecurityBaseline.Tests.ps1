param(
    [Parameter(Mandatory = $false)]
    [string]$PackageName = 'WinSecurityBaseline'
)

if (!(choco --version))
{
    Write-Host "Choco not installed - Installing..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$WorkingFiles = gci -Recurse
Write-Host $WorkingFiles
Write-Host $PackageName
$Nupkg = $WorkingFiles | ? {($_.Extension -eq '.nupkg') -and ($_.Name -match "$PackageName")}
Write-Host $Nupkg

Describe 'Chocolatey Packages Install' {
    It "Install: $PackageName" {
        $PkgInstall = $null
        $PkgInstall = choco install $Nupkg.FullName -y
        $PkgInstall | ?{$_ -match "The install of $PackageName was successful"} | Should -Not -Be $null
    }
}

choco install $Nupkg.FullName -y

Describe 'Chocolatey Package is listed' {
    It "Listed" {
        $PkgList = $null
        $PkgList = choco list --local-only
        $PkgList | ?{$_ -match $PackageName} | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package Contents exist' {
    It "$PackageName" {
        $PkgContents = $null
        $PkgContents = gci -Path "${env:ProgramFiles(x86)}\$PackageName" -Recurse
        $PkgContents | Should -Not -Be $null
    }
}

Describe 'Chocolatey Package Uninstall' {
    It "Uninstall: $PackageName" {
        $PkgUninstall = $null
        $PkgUninstall = choco uninstall $PackageName -y
        $PkgUninstall | ?{$_ -match "$PackageName has been successfully uninstalled"} | Should -Not -Be $null
    }
}
