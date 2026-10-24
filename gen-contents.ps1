param (
  [Parameter(Position=0)]
  [string]$packDir = (Get-Location),
  
  [string]$contentsFile = "contents.json"
)

# Define allowed file extensions
$allowedExtensions = @('*.json', '*.png', '*.tga', '*.hdr', '*.lang')

# Get all matching files recursively, excluding the target file itself
$files = Get-ChildItem -Path $packDir -Recurse -File -Include $allowedExtensions -Exclude $contentsFile

# Use generic List to ensure correct JSON array serialization even for a single file
$contentsList = [System.Collections.Generic.List[object]]::new()

foreach ($file in $files) {
  # Calculate relative path
  $relativePath = $file.FullName.Substring($packDir.Length).TrimStart('\', '/')
  
  # Replace backslashes with forward slashes
  $relativePath = $relativePath -replace '\\', '/'
  
  # Add to list
  $contentsList.Add(@{ path = $relativePath })
}

# Build root object
$rootObject = @{
  content = $contentsList
}

# Convert to JSON and enforce LF line endings
$jsonContent = $rootObject | ConvertTo-Json
$jsonContent = $jsonContent.Replace("`r`n", "`n")

# Set output file path
$outputPath = Join-Path $packDir $contentsFile

# Write to file using UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputPath, $jsonContent, $utf8NoBom)

Write-Host "Successfully generated $contentsFile with $($contentsList.Count) files." -ForegroundColor Green
