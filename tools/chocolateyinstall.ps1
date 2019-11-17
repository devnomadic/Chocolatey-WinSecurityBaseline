$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir  = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$arguments = Get-PackageParameters

$SecBaseLineUrl = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2010%20Version%201903%20and%20Windows%20Server%20Version%201903%20Security%20Baseline%20-%20Sept2019Update.zip' # download url, HTTPS preferred
$LGPOUrl        = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip'

$SecBaseLinePackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\WinSecBaseline"
  url           = $SecBaseLineUrl
  checksum      = 'F51FC91A6E5CEEE9D965F2D12319DEFA25073101421D212F95F40A402DDA7740'
  checksumType  = 'sha256'
  silentArgs    = ''
}

$LGPOPackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\WinSecBaseline\Scripts\Tools"
  url           = $LGPOUrl
  checksum      = '6FFB6416366652993C992280E29FAEA3507B5B5AA661C33BA1AF31F48ACEA9C4'
  checksumType  = 'sha256'
  silentArgs    = ''
}

Install-ChocolateyZipPackage @SecBaseLinePackageArgs
Install-ChocolateyZipPackage @LGPOPackageArgs

#Run Microsoft PS1 installer
if ($arguments.ContainsKey("OSType")) {
  Write-Host "OSType Argument Found"
  $OSType = $arguments["OSType"]
  if ($OSType -notmatch "Server|Worstation"){
    Throw "Arguments must be either 'server' or 'workstaiton'"
  }
}
else{
  $OSType = 'Server'
} 

$ScriptInstallerPath = "${env:ProgramFiles(x86)}\WinSecBaseline\Scripts\Baseline-LocalInstall.ps1"

if ($OSType -eq 'Server'){
  & $ScriptInstallerPath -WSNonDomainJoined
}
elseif ($OSType -eq 'Workstation'){
  & $ScriptInstallerPath -Win10NonDomainJoined
}
else {
  Throw "Error selection powershell arguments"
}