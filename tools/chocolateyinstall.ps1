$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir  = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$arguments = Get-PackageParameters

$OSVersion = [System.Environment]::OSVersion.Version

# Windows Server 2022 has build 20348, Windows 11 has build 22000+
# This check excludes Windows 10 (builds < 20348) and Windows Server 2019 (build 17763)
if($OSVersion.Major -lt 10 -or $OSVersion.Build -lt 20348){
  throw "Windows build must be Windows 11+ or Windows Server 2022+"
}

$SecBaseLineUrl = 'https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/Windows%20Server%202022%20Security%20Baseline.zip' # download url, HTTPS preferred
$LGPOUrl        = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip'

$SecBaseLinePackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName"
  url           = $SecBaseLineUrl
  checksum      = '49590CC694626D171FC934FAFEA6494F13ECD3843086704B7A5B98355909B8E0'
  checksumType  = 'sha256'
  silentArgs    = ''
}

$LGPOPackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Windows Server-2022-Security-Baseline-FINAL\Scripts\Tools"
  url           = $LGPOUrl
  checksum      = 'CB7159D134A0A1E7B1ED2ADA9A3CE8CE8F4DE391D14403D55438AF824247CC55'
  checksumType  = 'sha256'
  silentArgs    = ''
}

Install-ChocolateyZipPackage @SecBaseLinePackageArgs
Install-ChocolateyZipPackage @LGPOPackageArgs

#If unzip does not place LPGO.exe in tools directory then move it
if (!(Test-Path -Path "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Windows Server-2022-Security-Baseline-FINAL\Scripts\Tools\LGPO.exe")){
    $gci = Get-ChildItem -Path "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\" -Filter '*LGPO.exe' -Recurse
    if ($gci){
        Move-Item -Path $gci[0].FullName -Destination "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Windows Server-2022-Security-Baseline-FINAL\Scripts\Tools\$($gci.name)"
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

$ScriptInstallerPath = "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Windows Server-2022-Security-Baseline-FINAL\Scripts\Baseline-LocalInstall.ps1"
cd "${env:ProgramFiles(x86)}\$env:ChocolateyPackageName\Windows Server-2022-Security-Baseline-FINAL\Scripts\"

if ($OSType -eq 'Server'){
  & $ScriptInstallerPath -WSNonDomainJoined
}
elseif ($OSType -eq 'Workstation'){
  & $ScriptInstallerPath -Win10NonDomainJoined
}
else {
  Throw "Error selection powershell arguments"
}
