import re

def extract_midgetblaster_files(duplicates_file):
    """Extract filenames and duplicate assets from duplicates.txt, filtering only midgetblaster files."""
    duplicates = {}
    with open(duplicates_file, 'r', encoding='utf-8') as file:
        for line in file:
            match = re.search(r"ERROR: Duplicate '(.*?)' asset '(.+?)' found in (.+?_midgetblaster.+?):", line)
            if match:
                asset_name = match.group(2).strip()
                gdt_file = match.group(3).strip()
                duplicates.setdefault(gdt_file, set()).add(asset_name)
    return duplicates

def remove_assets_from_gdt(gdt_file, assets_to_remove):
    """Completely remove asset blocks with improved flexibility in pattern matching."""
    with open(gdt_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    # **Improved regex**: Handles extra spaces and variations
    pattern = re.compile(r'^\s*"(.+?)"\s*\(\s*"(.+?)"\s*\)\s*\{?$', re.MULTILINE)

    with open(gdt_file, 'w', encoding='utf-8') as file:
        inside_asset_block = False
        current_asset = None

        for line in lines:
            stripped_line = line.strip()
            match = pattern.match(stripped_line)

            if match:
                current_asset = match.group(1).strip()
                inside_asset_block = current_asset in assets_to_remove  # Mark block for removal
            
            if inside_asset_block and stripped_line == "}":  # Detect closing bracket
                inside_asset_block = False
                current_asset = None
                continue  # Skip closing bracket
            
            if not inside_asset_block:
                file.write(line)

def main():
    duplicates_file = "duplicates.txt"
    
    duplicates = extract_midgetblaster_files(duplicates_file)
    for gdt_file, assets in duplicates.items():
        print(f"Cleaning {gdt_file}... Removing {', '.join(assets)}")
        remove_assets_from_gdt(gdt_file, assets)
    
    print("Finished processing all midgetblaster files!")

if __name__ == "__main__":
    main()
