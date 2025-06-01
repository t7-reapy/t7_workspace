import re

def extract_invalid_entities(error_log):
    """Extract affected filenames and entity names from GDT parse errors, with tracing."""
    invalid_entities = {}
    print(f"📖 Reading error log: {error_log}")

    with open(error_log, 'r', encoding='utf-8') as file:
        for line in file:
            match = re.search(r"GDT ParseError: File '(.+?_midgetblaster.+?) \(@ line:(\d+)\)' Parent Entity '(.*?)' does not exist in GDT", line)
            if match:
                gdt_file = match.group(1).strip()
                entity_name = match.group(3).strip()
                invalid_entities.setdefault(gdt_file, set()).add(entity_name)
                print(f"⚠️ Found missing parent reference: {entity_name} in {gdt_file}")

    return invalid_entities

def remove_invalid_entities(gdt_file, entities_to_remove):
    """Remove **entire entity blocks** referencing missing parents, with tracing."""
    print(f"🛠 Processing: {gdt_file} - Removing {len(entities_to_remove)} entities")
    
    with open(gdt_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    pattern = re.compile(r'^\s*"(.+?)"\s*\[\s*"(.+?)"\s*\]\s*$', re.MULTILINE)

    with open(gdt_file, 'w', encoding='utf-8') as file:
        inside_entity_block = False
        current_entity = None

        for line in lines:
            stripped_line = line.strip()
            match = pattern.match(stripped_line)

            if match:
                current_entity = match.group(1).strip()
                parent_entity = match.group(2).strip()
                
                # Check if the parent entity is missing and mark the block for removal
                inside_entity_block = parent_entity in entities_to_remove  
                
                if inside_entity_block:
                    print(f"🗑️ Removing full block: {current_entity} (Parent: {parent_entity})")

            # Skip all lines inside the block until we reach the closing bracket
            if inside_entity_block and stripped_line == "}":  
                inside_entity_block = False
                current_entity = None
                continue  # Skip closing bracket
            
            if not inside_entity_block:
                file.write(line)

def main():
    error_log = "duplicate_parent.txt"  # Replace with actual error log file
    invalid_entities = extract_invalid_entities(error_log)

    for gdt_file, entities in invalid_entities.items():
        print(f"🔍 Cleaning {gdt_file}... Removing references to {', '.join(entities)}")
        remove_invalid_entities(gdt_file, entities)
    
    print("✅ Finished processing all affected files!")

if __name__ == "__main__":
    main()
