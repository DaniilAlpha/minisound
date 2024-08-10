import os
import re
import argparse

def load_yaml_preserve_structure(file_path):
    with open(file_path, 'r') as file:
        return file.read()

def update_yaml_content(content, new_version, is_release, local_packages):
    # Update version
    content = re.sub(r'^version:.*$', f'version: {new_version}', content, flags=re.MULTILINE)
   
    # Regex to match dependencies block correctly
    dep_pattern = re.compile(r'^dependencies:(.*?)(?=^(\w|#)|\Z)', re.DOTALL | re.MULTILINE)
    dep_match = dep_pattern.search(content)
   
    if dep_match:
        dep_content = dep_match.group(0).split('\n')
        updated_deps = ['dependencies:']
        current_package = None
        current_indent = None
        local_package_paths = {}
        for line in dep_content[1:]:  # Skip the 'dependencies:' line
            package_match = re.match(r'^(\s*)(\w+):', line)
            if package_match:
                current_indent = package_match.group(1)
                current_package = package_match.group(2)
                if current_package in local_packages:
                    if is_release:
                        updated_deps.append(f'{current_indent}{current_package}: ^{new_version}')
                    else:
                        updated_deps.append(f'{current_indent}{current_package}:')
                        local_package_paths[current_package] = f'{current_indent}  path: ../{current_package}'
                else:
                    updated_deps.append(line)
            elif line.strip().startswith('path:') and current_package in local_packages:
                # Skip path lines for local packages
                continue
            else:
                updated_deps.append(line)
       
        # Add path lines for local packages if not in release mode
        if not is_release:
            for package, path_line in local_package_paths.items():
                if path_line not in updated_deps:
                    package_index = updated_deps.index(f'  {package}:')
                    updated_deps.insert(package_index + 1, path_line)
        else:
            # Remove path lines for local packages in release mode
            updated_deps = [line for line in updated_deps if not line.strip().startswith('path:')]
       
        new_dep_content = '\n'.join(updated_deps)
        content = dep_pattern.sub(new_dep_content, content)
   
    # Ensure proper separation between dependencies and dev_dependencies
    content = re.sub(r'(\n\s*\w+:.*\n*)dev_dependencies:', r'\1dev_dependencies:', content)
   
    # Update publish_to field
    publish_pattern = re.compile(r'^publish_to:.*$', re.MULTILINE)
    if is_release:
        content = publish_pattern.sub('', content)
    else:
        if publish_pattern.search(content):
            content = publish_pattern.sub('publish_to: none', content)
        else:
            content = f'publish_to: none{content}'
   
    return content

def add_newlines_before_sections(content):
    section_patterns = [r'^dependencies:', r'^dev_dependencies:']
    for pattern in section_patterns:
        content = re.sub(f'(?<!\n\n){pattern}', f'\n\n{pattern}', content)
    return content

def process_pubspec(file_path, new_version, is_release, local_packages):
    content = load_yaml_preserve_structure(file_path)
    updated_content = update_yaml_content(content, new_version, is_release, local_packages)
    final_content = add_newlines_before_sections(updated_content)
    
    with open(file_path, 'w') as file:
        file.write(final_content)

def main(version, is_release):
    root_dir = os.path.dirname(os.path.abspath(__file__))
    packages = ["minisound", "minisound_platform_interface", "minisound_ffi", "minisound_web"]

    for dir_name in packages:
        pubspec_path = os.path.join(root_dir, dir_name, "pubspec.yaml")
        if os.path.exists(pubspec_path):
            process_pubspec(pubspec_path, version, is_release, packages)
            print(f"Updated {pubspec_path}")
        else:
            print(f"Warning: {pubspec_path} not found")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update pubspec files for release or local development.")
    parser.add_argument("version", help="The new version number Ex. update_pubspecs.py 1.0.0")
    parser.add_argument("--release", action="store_true", help="Prepare for release (default is local development)")
    args = parser.parse_args()
    main(args.version, args.release)