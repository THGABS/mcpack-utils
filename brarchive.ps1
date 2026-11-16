param (
  [Parameter(Position=0)]
  [string]$packDir = (Get-Location),
  
  [Parameter(Position=1)]
  [string]$outputDir = $packDir,
  
  [string]$packName = (Split-Path -Path $packDir -Leaf),
  [string]$brarchiveDir = (Split-Path -Path $packDir -Parent | Join-Path -ChildPath "brarchive/$packName")
)

$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Archive-Pack {
  # Copy root files and br-archive other contents
  param (
    [Parameter(Position=0)]
    [string]$packDir = $packDir,

    [Parameter(Position=1)]
    [string]$archiveDir = $brarchiveDir,

    [string]$packName = (Split-Path -Path $packDir -Leaf)
  )
  # Create if not exist
  if (!(Test-Path $archiveDir -PathType Container)) {
    New-Item -Path $archiveDir -ItemType "Directory"
  }

  # Copy root files
  $rootFiles = Get-ChildItem -Path $packDir/* -File -Include *.json, *.png, *.md
  $rootFileCount = $rootFiles.Count
  if ($rootFiles) {
    Copy-Item -Path $rootFiles -Destination $archiveDir
    Write-Host "$rootFileCount root files in $packName are successfully copied."
  }

  # Br-archive contents
  if (Get-ChildItem -Path $packDir -Directory) {
    brarchive encode --recursive --skip-root $packDir $archiveDir
  }
  Write-Host "The pack $packName is successfully archived."
  Write-Host
}

function Remove-Leftover {
  # Remove extra brarchives
  param (  
    [Parameter(Position=0)]
    [string]$dir = $brarchiveDir,

    [Parameter(ValueFromRemainingArguments, Position=1)]
    [string[]]$toRemoveArr = "subpacks"
  )
  $workDir = Join-Path $dir __brarchive
  foreach ($toRemove in $toRemoveArr) {
    $toRmPath = Join-Path $workDir $toRemove
    if (Test-Path -Path $toRmPath -PathType Leaf) {
      Remove-Item $toRmPath
      Write-Host "File $toRemove is removed."
    }
    elseif (Test-Path -Path $toRmPath -PathType Container) {
      Remove-Item -Recurse $toRmPath
      Write-Host "Directory $toRemove is removed."
    }
    else {
      Write-Host "File or Directory $toRemove is not found."
    }
  }
  Write-Host
}

# Archive the main pack
Archive-Pack $packDir $brarchiveDir -packName $packName
Remove-Leftover $brarchiveDir subpacks

# Archive subpacks
$subpackDir = Join-Path $packDir "subpacks"
if (Test-Path $subpackDir -PathType Container) {
  $brarchiveSubpackDir = Join-Path $brarchiveDir "subpacks"
  Get-ChildItem -Directory $subpackDir | ForEach-Object -Process{
    $subpackName = $_.Name
    $thisBrSubpackDir = Join-Path $brarchiveSubpackDir $subpackName
    Archive-Pack $_ $thisBrSubpackDir
    # Remove-Leftover $thisBrSubpackDir "$subpackName.brarchive"
  }
}
else {
  Write-Host "No subpack found in $packName"
}

Write-Host "Br-archive Completed!" -ForegroundColor Green
Write-Host

# Zip the pack to a mcpack file
Read-Host -Prompt "Press Enter to make a mcpack, or Ctrl + C to exit"
zip-pack.ps1 -packDir $brarchiveDir -outputDir $outputDir -packName $packName
