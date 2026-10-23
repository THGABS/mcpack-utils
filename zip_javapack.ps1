# Zip your resource/data pack for Java Edition
$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$packName = Get-Location | Split-Path -Leaf
# Directory of pack archives
$outputDir = "/path/to/packs"
# Extension of the pack archive
$extName = "zip"
$zipFile = Join-Path -Path $outputDir -ChildPath "$packName.$extName"
7z a -tzip $zipFile -r @listfile/java.txt -mx9 -uq0
