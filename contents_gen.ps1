param (
  [Parameter(Position=0)]
  [string]$packDir = (Get-Location),
  
  [string]$contentsFilename = "contents.json"
)

# Define allowed file extensions
$allowedExtensions = @('*.json', '*.png', '*.tga', '*.hdr', '*.lang')

# Get all matching files recursively, excluding the target file itself
$files = Get-ChildItem -Path $packDir -Recurse -File -Include $allowedExtensions -Exclude $contentsFilename

# Use generic List to ensure correct JSON array serialization even for a single file
$contentList = [System.Collections.Generic.List[object]]::new()

foreach ($file in $files) {
  # Calculate relative path
  $relativePath = $file.FullName.Substring($packDir.Length).TrimStart('\', '/')
  
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
$outputPath = Join-Path $packDir $contentsFilename

# Write to file using UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputPath, $jsonContent, $utf8NoBom)

Write-Host "Successfully generated $contentsFilename with $($contentList.Count) files." -ForegroundColor Green
