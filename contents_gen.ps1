# Get current directory path
$currentDir = (Get-Location).Path
$targetFileName = "contents.json"

# Define allowed file extensions
$allowedExtensions = @('*.json', '*.png', '*.tga', '*.hdr', '*.lang')

# Get all matching files recursively, excluding the target file itself
$files = Get-ChildItem -Path $currentDir -Recurse -File -Include $allowedExtensions -Exclude $targetFileName

# Use generic List to ensure correct JSON array serialization even for a single file
$contentList = [System.Collections.Generic.List[object]]::new()

foreach ($file in $files) {
  # Calculate relative path
  $relativePath = $file.FullName.Substring($currentDir.Length).TrimStart('\', '/')
  
  # Replace backslashes with forward slashes
  $relativePath = $relativePath -replace '\\', '/'
  
  # Add to list
  $contentList.Add(@{ path = $relativePath })
}

# Build root object
$rootObject = @{
  content = $contentList
}

# Convert to JSON and enforce LF line endings
$jsonContent = $rootObject | ConvertTo-Json
$jsonContent = $jsonContent.Replace("`r`n", "`n")

# Set output file path
$outputPath = Join-Path $currentDir $targetFileName

# Write to file using UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputPath, $jsonContent, $utf8NoBom)

Write-Host "Successfully generated $targetFileName with $($contentList.Count) files." -ForegroundColor Green
