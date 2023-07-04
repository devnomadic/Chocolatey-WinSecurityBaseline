$ErrorActionPreference = 'Stop'; # stop on all errors

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  ZipFileName   = 'Windows 10 Version 1809 and Windows Server 2019 Security Baseline.zip'
}

Uninstall-ChocolateyZipPackage @packageArgs
