# Zip your Minecraft pack
param (
  [Parameter(Mandatory, Position=0)]
  [string]$packDir,

  [Parameter(Position=1)]
  [string]$outputDir,

  [string]$packName,
  [switch]$isJava
)

$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
if (-not $outputDir) {
  $outputDir = $packDir
}
if (-not $packName) {
  $packName = Split-Path -Path $packDir -Leaf
}

# Extension of the pack archive
$extName = "mcpack"
$listfile = "$PSScriptRoot/listfile/bedrock.txt"
if ($isJava) {
  $extName = "zip"
  $listfile = "$PSScriptRoot/listfile/java.txt"
}

$zipFile = Join-Path -Path $outputDir -ChildPath "$packName.$extName"
7z a -tzip $zipFile -r @$listfile -mx9 -uq0
