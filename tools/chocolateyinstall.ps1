$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir  = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$arguments = Get-PackageParameters

$OSVersion = [System.Environment]::OSVersion.Version

# Windows Server 2022 has build 20348, Windows 11 has build 22000+
# This check excludes Windows 10 (builds < 20348) and Windows Server 2019 (build 17763)
if($OSVersion.Major -lt 10 -or $OSVersion.Build -lt 20348){
  throw "Windows build must be Windows 11+ or Windows Server 2022+"
}

$SecBaseLineUrl = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%20Server%202022%20Security%20Baseline.zip' # download url, HTTPS preferred
$LGPOUrl        = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip'

$SecBaseLinePackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName"
  url           = $SecBaseLineUrl
  checksum      = '3BDFB976546BE0EE4CE8B220A56E5A26C3ACBBB844DA00B6F9B2DD26D9CA0A04'
  checksumType  = 'sha256'
  silentArgs    = ''
}

$LGPOPackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Local_Script\Tools"
  url           = $LGPOUrl
  checksum      = '6FFB6416366652993C992280E29FAEA3507B5B5AA661C33BA1AF31F48ACEA9C4'
  checksumType  = 'sha256'
  silentArgs    = ''
}

Install-ChocolateyZipPackage @SecBaseLinePackageArgs
Install-ChocolateyZipPackage @LGPOPackageArgs

#If unzip does not place LPGO.exe in tools directory then move it
if (!(Test-Path -Path "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Local_Script\Tools\LGPO.exe")){
    $gci = Get-ChildItem -Path "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Local_Script\Tools\" -Filter '*LGPO.exe' -Recurse
    if ($gci){
        Move-Item -Path $gci[0].FullName -Destination "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Local_Script\Tools\$($gci.name)"
    }
    else{
        throw "Unable to find LGPO.exe"
    }
}

#Run Microsoft PS1 installer
if ($arguments.ContainsKey("OSType")) {
  Write-Host "OSType Argument Found"
  $OSType = $arguments["OSType"]
  if ($OSType -notmatch "Server|Workstation"){
    Throw "Arguments must be either 'server' or 'workstation'"
  }
}
else{
  $OSType = 'Server'
} 

$ScriptInstallerPath = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Local_Script\BaselineLocalInstall.ps1"

if ($OSType -eq 'Server'){
  & $ScriptInstallerPath -WS2022NonDomainJoined
}
elseif ($OSType -eq 'Workstation'){
  & $ScriptInstallerPath -Win11NonDomainJoined
}
else {
  Throw "Error selection powershell arguments"
}
