# Zip your Minecraft pack
param (
  [Parameter(Position=0)]
  [string]$packDir = (Get-Location).Path,

  [Parameter(Position=1)]
  [string]$outputDir = $packDir,

  [string]$packName = (Split-Path -Path $packDir -Leaf)
)

function Test-File {
  param (
    [Parameter(Position=0)]
    [string]$filename,
    
    [string]$dir = $packDir
  )
  Join-Path -Path $dir -ChildPath $filename | Test-Path -PathType Leaf
}

$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$initDir = (Get-Location).Path

# Decide the edition that your pack is for
# Default
$extName = "zip"
$toZip = "*"
# Is Java
if (Test-File pack.mcmeta) {
  $toZip = "@$PSScriptRoot/listfile/java.txt"
}
# Is Bedrock
elseif (Test-File manifest.json) {
  $extName = "mcpack"
  $toZip = "@$PSScriptRoot/listfile/bedrock.txt"
}

$zipFile = Join-Path -Path $outputDir -ChildPath "$packName.$extName"
Set-Location $packDir
7z a -tzip $zipFile $toZip -r -mx9 -uq0
Set-Location $initDir
