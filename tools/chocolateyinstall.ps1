$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir  = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$arguments = Get-PackageParameters

$OSVersion = [System.Environment]::OSVersion.Version

if($OSVersion.Major -lt 10){
  throw "Windows build must be Windows10+ or Server2016+"
}

$SecBaseLineUrl = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2010%20Version%201809%20and%20Windows%20Server%202019%20Security%20Baseline.zip' # download url, HTTPS preferred
$LGPOUrl        = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip'

$SecBaseLinePackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName"
  url           = $SecBaseLineUrl
  checksum      = '575DDAF39EF364EA6DA678E22B0A988EA316EB240F73FBF618092A02647245BC'
  checksumType  = 'sha256'
  silentArgs    = ''
}

$LGPOPackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Local_Script\Tools"
  url           = $LGPOUrl
  checksum      = 'CB7159D134A0A1E7B1ED2ADA9A3CE8CE8F4DE391D14403D55438AF824247CC55'
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
  & $ScriptInstallerPath -WS2019NonDomainJoined
}
elseif ($OSType -eq 'Workstation'){
  & $ScriptInstallerPath -Win10NonDomainJoined
}
else {
  Throw "Error selection powershell arguments"
}
