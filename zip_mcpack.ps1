# Zip your pack in raw format (instead of brarchive)
$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$packName = Get-Location | Split-Path -Leaf
# Directory of mcpack archives
$outputDir = "/path/to/mcpacks"
# Extension of the pack archive
$extName = "mcpack"
$zipFile = Join-Path -Path $outputDir -ChildPath "$packName.$extName"
7z a -tzip $zipFile -r *.png *.tga *.hdr *.lang *.json *.md -mx9 -uq0
