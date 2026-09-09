$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$originalDir = Get-Location
$packName = Split-Path $originalDir -Leaf
# The directory of brarchived pack
$brarchiveDir = "../$packName-"
# Create if not exist
if (!(Test-Path $brarchiveDir -PathType Container)) {
  New-Item -Path "../" -Name "$packName-" -ItemType "Directory"
}
# Copy root files
Get-ChildItem -Path ./* -File -Include *.json, *.png, *.md | Copy-Item -Destination $brarchiveDir
Write-Host "Root files are successfully copied."
brarchive-cli encode -rd . $brarchiveDir
Write-Host "The main pack $packName is archived."
# Archive subpacks
$subDirName = "subpacks"
$brarchiveSubDir = Join-Path $brarchiveDir $subDirName
if (Test-Path $subDirName -PathType Container) {
  Get-ChildItem -Directory ./$subDirName | ForEach-Object -Process{
    $subpackName = $_.Name
    $brarchiveSubpackDir = Join-Path $brarchiveSubDir $subpackName
    # Create if not exist
    if (!(Test-Path $brarchiveSubpackDir -PathType Container)) {
      New-Item -Path $brarchiveSubDir -Name $subpackName -ItemType "Directory"
    }
    $subpackRootFiles = Get-ChildItem -Path $_/* -File -Include *.json
    $subpackRootFileCount = $subpackRootFiles.Count
    if ($subpackRootFileCount) {
      Copy-Item -Path $subpackRootFiles -Destination $brarchiveSubpackDir
    }
    Write-Host "$subpackRootFileCount root files in $subpackName are successfully copied."
    if (Get-ChildItem -Path $_ -Directory) {
      brarchive-cli encode -rd $_ $brarchiveSubpackDir
    }
    Write-Host "The subpack $subpackName is archived."
  }
}
else {
  Write-Host "No subpack detected!"
}
# Remove extra brarchives
$toRemove = "root.brarchive", "subpacks"
foreach ($toRm in $toRemove) {
  $toRmPath = "$brarchiveDir/__brarchive/$toRm"
  if (Test-Path -Path $toRmPath -PathType Leaf) {
    Remove-Item $toRmPath
    Write-Host "File $toRm is removed."
  }
  elseif (Test-Path -Path $toRmPath -PathType Container) {
    Remove-Item -Recurse $toRmPath
    Write-Host "Directory $toRm is removed."
  }
}
# Remove in subpack directory
if (Test-Path $brarchiveSubDir -PathType Container) {
  Get-ChildItem -Directory $brarchiveSubDir | ForEach-Object -Process {
    $subpackName = $_.Name
    $toRm = "$_/__brarchive/$subpackName.brarchive"
    if (Test-Path -Path $toRm -PathType Leaf) {
      Remove-Item $toRm
      Write-Host "$subpackName.brarchive is removed."
    }
  }
}
else {
  Write-Host "No subpack detected in $brarchiveDir!"
}
Write-Host "Br-archive Completed!" -ForegroundColor Green
# Zip the pack to a mcpack file
Read-Host -Prompt "Press Enter to make a mcpack, or Ctrl + C to exit"
Set-Location $brarchiveDir
# Set your directory of mcpack files here...
$outputDir = "path/to/mcpacks"
$extName = "mcpack"
$zipFile = Join-Path -Path $outputDir -ChildPath "$packName-.$extName"
# Need 7z to do this
7z a -tzip $zipFile -r *.brarchive *.png *.lang *.json *.md -mx9 -aoa
Write-Host "Successfully archived as $zipFile" -ForegroundColor Green
Set-Location $originalDir
