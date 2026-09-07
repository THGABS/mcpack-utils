# mcpack-utils

Utilities for working with Minecraft packs.

## Tools

- `contents_gen.ps1` — PowerShell script to scan a pack directory and generate a `contents.json` manifest listing JSON, texture, and language files.
- `texture_list_gen.py` — Python CLI to generate a `textures_list.json` in each `textures/` folder (optionally recursing into `subpacks`), or to print texture paths.
- `brarchive.ps1` — PowerShell utility that uses brarchive-cli to encode a pack and its subpacks, cleans up intermediary files, and zips the result into a `.mcpack` archive (optional).

## Features

- Create standardized `contents.json` file for packs.
- Generate `texture_list.json` files for textures in your resource pack/subpack.
- Archive pack contents to `.brarchive` files and produce `.mcpack` archives.

## Requirements

- [PowerShell](https://github.com/PowerShell/PowerShell) (Windows PowerShell or PowerShell Core/pwsh)
- [Python](https://www.python.org/) 3.8+ (for texture_list_gen.py)
- [brarchive-cli](https://github.com/bedrock-crustaceans/brarchive) (for pack encoding used by brarchive.ps1)
- [7-Zip](https://github.com/ip7z/7zip) (7z CLI) for creating .mcpack zip files

## Quick start

1. Clone the repo:
   ```bash
   git clone https://github.com/THGABS/mcpack-utils.git
   cd mcpack-utils
   ```

2. Run the scripts from your pack directory (examples below assume you copy the script(s) into your pack folder or call them with a full path).

### Generate `contents.json`
From the root of the pack (where you want contents.json):
```powershell
pwsh /path/to/mcpack-utils/contents_gen.ps1
# OR on Windows PowerShell:
powershell -ExecutionPolicy Bypass -File .\contents_gen.ps1
```
This writes `contents.json` in the current directory listing files with extensions: `.json`, `.png`, `.tga`, `.hdr`, `.lang`.

### Generate `textures_list.json`
Generate `textures_list.json` inside the `textures/` folder for the given pack:
```bash
python3 /path/to/mcpack-utils/texture_list_gen.py /path/to/pack
# Options:
#   -s, --subpacks   also generate texture lists for subpacks (if /subpacks exists)
#   -d, --display    print the texture list to stdout instead of creating files
```
Example:
```bash
python texture_list_gen.py . -s
```

### Make your pack in brarchive
The brarchive.ps1 script expects to be run from the pack folder. It:
- Encodes your pack contents in brarchive format
- Also deal with subpacks properly if a `subpacks/` directory exists
- Removes extra brarchive items that do not work
- Files in the pack's root directory will stay untouched
- Uses 7z to create a `.mcpack` archive in the configured output path (optional)

Example (from pack root):
```powershell
pwsh /path/to/mcpack-utils/brarchive.ps1
# It will prompt "Press Enter to output, or Ctrl + C to exit" before zipping.
```
Note: Update `$outputDir` inside `brarchive.ps1` (line ~58) to the desired output directory for the final `.mcpack` file.

## Examples

- Generate `content.json` and `textures_list.json`, then archive:
  ```bash
  pwsh /path/to/mcpack-utils/contents_gen.ps1
  python3 /path/to/mcpack-utils/texture_list_gen.py . -s
  pwsh /path/to/mcpack-utils/brarchive.ps1
  ```

## Contributing

Contributions, bug reports and improvements are welcome. If you want this repository to support additional features, open an issue or create a pull request describing the use case.
