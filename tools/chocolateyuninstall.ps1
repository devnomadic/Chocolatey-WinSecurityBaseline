$ErrorActionPreference = 'Stop'; # stop on all errors

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  ZipFileName   = 'Windows Server 2022 Security Baseline.zip'
}

Uninstall-ChocolateyZipPackage @packageArgs
