$ErrorActionPreference = 'Stop'; # stop on all errors

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  ZipFileName   = 'Windows 10 Version 1903 and Windows Server Version 1903 Security Baseline - Sept2019Update.zip'
}

$uninstalled = $false

function Uninstall-ChocolateyZipPackageFix {
  param(
    [parameter(Mandatory=$true, Position=0)][string] $packageName,
    [parameter(Mandatory=$true, Position=1)][string] $zipFileName,
    [parameter(ValueFromRemainingArguments = $true)][Object[]] $ignoredArguments
  )

  Write-FunctionCallLogMessage -Invocation $MyInvocation -Parameters $PSBoundParameters

  $packagelibPath=$env:chocolateyPackageFolder
  $zipContentFile=(join-path $packagelibPath $zipFileName) + "Install.txt"

  # The Zip Content File may have previously existed under a different
  # name.  If *Install.txt doesn't exist, check for the old name
  if(-Not (Test-Path -Path $zipContentFile)) {
    $zipContentFile=(Join-Path $packagelibPath -ChildPath $zipFileName) + ".txt"
  }

  if ((Test-Path -path $zipContentFile)) {
    $zipContentFile
    $zipContents=get-content $zipContentFile
    foreach ($fileInZip in $zipContents) {
      if ($fileInZip -ne $null -and $fileInZip.Trim() -ne '') {
        Remove-Item -Path "$fileInZip" -ErrorAction SilentlyContinue -Recurse -Force
      }
    }
  }

}

Uninstall-ChocolateyZipPackage @packageArgs
