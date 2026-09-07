import json
import os.path

indent: str|int|None = 2
eol: str|None = '\n'
textures_dirname: str = 'textures'
textures_list_filename: str = 'textures_list.json'
default_pattern = r'(.+)\.(hdr|tga|png|jpg)'

def walk_dir(root_path: str):
  '''
    Walk through the root path and return a list of file paths.
  '''
  from os import walk
  if not os.path.isdir(root_path):
    raise NotADirectoryError
  ls=[]
  for root, dirs, files in walk(root_path):
    for file in files:
      ls.append(os.path.join(root, file).replace('\\','/'))
  return ls

def extract_list(str_list: list[str], pattern: str, group: int=0, unique: bool = True):
  '''
    Extract specific part from each string that matches the pattern in a string list.
  '''
  import re
  if unique:
    extracted = set()
    extract = lambda x: extracted.add(x)
  else:
    extracted = list()
    extract = lambda x: extracted.append(x)
  regex = re.compile(pattern)
  for string in str_list:
    match = regex.match(string)
    if match:
      extract(match.group(group).replace('\\','/'))
  return list(extracted)

def get_texture_list(pack_path: str, to_extract_pattern: str = default_pattern, part: int = 1):
  '''
    Return a list of file path with given pattern.
    - `pack_path`: Path of the pack directory
    - `filepath_pattern`: Regular expression pattern of the file path (relative to `pack_path`)
    - `part`: The group to be extracted in your R.E. pattern (start from `1`)
  '''
  textures_path = os.path.join(pack_path, textures_dirname)
  if os.path.isdir(textures_path):
    return extract_list(walk_dir(textures_path), '/'.join((pack_path.replace('\\','/').replace('.',r'\.'), to_extract_pattern)), part)
  return []
  
def main(pack_path: str, include_subpacks: bool = True, to_display: bool = False):
  '''
    To generate/print the texture list(s) for a particular pack.
    - `pack_path`: Path of the pack directory.
    - `include_subpacks`: Also generate texture lists for its subpacks.
    - `to_display`: Whether it should display or generate the texture list(s).
  '''
  def generate(pack_path: str):
    '''Generate a `texture_list.json` in the `textures` folder'''
    textures_path = os.path.join(pack_path, textures_dirname)
    if os.path.isdir(textures_path):
      filename = os.path.join(textures_path, textures_list_filename)
      try:
        with open(filename, 'w+', encoding='utf-8', errors='surrogateescape', newline=eol) as file:
          json.dump(get_texture_list(pack_path), file, indent=indent)
        print('Generated:', filename)
      except OSError as e:
        print(e)
    else:
      print('Invalid path:', textures_path)
  def display(pack_path: str):
    '''Print a texture list'''
    print('=={}=='.format(pack_path))
    for item in get_texture_list(pack_path):
      print(item)
    print()
  action = lambda x: display(x) if to_display else generate(x)
  action(pack_path)
  if include_subpacks:
    subpack_folder = os.path.join(pack_path, 'subpacks')
    if os.path.isdir(subpack_folder):
      from os import scandir
      subpacks = [entry for entry in scandir(subpack_folder) if entry.is_dir()]
      for subpack in subpacks:
        action(subpack.path)

if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser(prog='Texture List Generator')
  parser.add_argument('path', type=str, help='Path of the pack directory')
  parser.add_argument('-s', '--subpacks', action="store_true", help='Also generate texture lists for subpacks')
  parser.add_argument("-d", "--display", action="store_true",
      help="display the texture list, instead of generating a file")
  try:
    args = parser.parse_args()
  except:
    parser.print_help()
  else:
    main(args.path, include_subpacks=args.subpacks, to_display=args.display)
