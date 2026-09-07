# Zip your pack in raw format (instead of brarchive)
$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$packName = (Get-Location | Split-Path -Leaf)
# Set your output directory here...
$outputDir = "path/to/mcpacks"
$extName = "mcpack"
$zipFile = Join-Path -Path $outputDir -ChildPath "$packName.$extName"
7z a -tzip $zipFile -r *.png *.tga *.hdr *.lang *.json *.md -mx9 -aoa
