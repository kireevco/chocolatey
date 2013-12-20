function Chocolatey-Pack {
param(
  [string] $packageName,
  [string] $bumpBuild = '0'
)
  Write-Debug "Running 'Chocolatey-Pack' for $packageName. If nuspec name is not passed, it will find the nuspec file in the current working directory";

  $packageArgs = "pack $packageName -NoPackageAnalysis"
  $logFile = Join-Path $nugetChocolateyPath 'pack.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  
  if ([int]$bumpBuild -gt 0)
  {
		
	if ($packageName -like '')
	{
		Write-Host "No package name specified explicitly, can't bump the build version."
	}
	else
	{
	
		$nuspecFile = [xml](Get-Content $packageName)
		$packageVersion = $nuspecFile.package.metadata.version
		
		$packageVersionSplit = $packageVersion.Split('.')
		
		$packageVersionSplit[3] = [int]$bumpBuild + [int]$packageVersionSplit[3]
		$ofs = "."
		$versionStr = [string] $packageVersionSplit
		
		Write-Host "Bumping package build version from ${packageVersion} to ${versionStr}"
		$nuspecFile.package.metadata.version = $versionStr
		$nuspecFile.Save($packageName)
	}
  }
  
  Write-Host "Calling `'$nugetExe $packageArgs`'."
  
  Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    Write-Host $line
  }
  $errors = Get-Content $errorLogFile
  if ($errors -ne '') {
    Write-Host $errors -BackgroundColor Red -ForegroundColor White
    #throw $errors
  }
}