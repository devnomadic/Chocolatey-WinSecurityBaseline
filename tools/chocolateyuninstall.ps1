$ErrorActionPreference = 'Stop'; # stop on all errors

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  ZipFileName   = 'Windows 10 Version 1903 and Windows Server Version 1903 Security Baseline - Sept2019Update.zip'
}

Uninstall-ChocolateyZipPackage @packageArgs
