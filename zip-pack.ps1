# Zip your Minecraft pack
param (
  [Parameter(Position=0)]
  [string]$packDir = (Get-Location).Path,

  [Parameter(Position=1)]
  [string]$outputDir = $packDir,

  [string]$packName = (Split-Path -Path $packDir -Leaf),
  [switch]$isJava
)

$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$initDir = (Get-Location).Path

# Extension of the pack archive
$extName = "mcpack"
$listfile = "$PSScriptRoot/listfile/bedrock.txt"

if ($isJava) {
  $extName = "zip"
  $listfile = "$PSScriptRoot/listfile/java.txt"
}

$zipFile = Join-Path -Path $outputDir -ChildPath "$packName.$extName"
Set-Location $packDir
7z a -tzip $zipFile @$listfile -r -mx9 -uq0
Set-Location $initDir
