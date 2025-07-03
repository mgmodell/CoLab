import os
import json # Still needed for dummy JSON creation if you run the script directly for testing
import yaml # New import for YAML handling
from collections import deque

def get_all_keys(data, parent_key=''):
    """
    Recursively extracts all nested keys from a dictionary or list.
    Keys are represented in dot notation (e.g., 'messages.greeting.hello').
    """
    keys = set()
    if isinstance(data, dict):
        for k, v in data.items():
            current_key = f"{parent_key}.{k}" if parent_key else k
            keys.add(current_key)
            keys.update(get_all_keys(v, current_key))
    elif isinstance(data, list):
        # For lists, we don't typically create keys for array indices,
        # but we do recurse into objects within lists.
        for item in data:
            if isinstance(item, (dict, list)):
                keys.update(get_all_keys(item, parent_key))
    return keys

def load_locale_file(filepath):
    """
    Loads and parses a YAML locale file.
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: File not found at {filepath}")
        return None
    except yaml.YAMLError as e:
        print(f"Error: Invalid YAML in file {filepath}: {e}")
        return None
    except Exception as e:
        print(f"An unexpected error occurred while reading {filepath}: {e}")
        return None

def audit_locale_files(locale_dir):
    """
    Audits locale files for missing keys, grouping by feature.
    Assumes filenames are in the format <feature>.<lang>.yml or <feature>.<lang>.yaml.

    Args:
        locale_dir (str): The directory containing the locale files.
    """
    print(f"--- Auditing Locale Files in: {locale_dir} ---")
    print("Grouping files by feature (e.g., 'intro', 'candidates')...")
    print("-" * 40)

    # Dictionary to store files grouped by feature and language
    # Example: {'intro': {'en': 'intro.en.yml', 'es': 'intro.es.yml'}}
    feature_groups = {}

    for filename in os.listdir(locale_dir):
        if filename.endswith(('.yml', '.yaml')):
            parts = filename.rsplit('.', 2) # Split from right, max 2 times (e.g., 'intro.en.yml' -> ['intro', 'en', 'yml'])
            if len(parts) == 3:
                feature = parts[0]
                lang = parts[1]
                if feature not in feature_groups:
                    feature_groups[feature] = {}
                feature_groups[feature][lang] = filename
            else:
                print(f"Warning: Skipping '{filename}' - does not match <feature>.<lang>.yml format.")

    if not feature_groups:
        print("No locale files found matching the <feature>.<lang>.yml format.")
        return

    # Now, iterate through each feature group and perform the audit
    for feature, languages in sorted(feature_groups.items()):
        source_filename = languages.get('en') # Assuming 'en' is always the source language
        if not source_filename:
            print(f"\n--- Skipping Feature: '{feature}' ---")
            print(f"No 'en' (English) locale file found for feature '{feature}'. Cannot establish a source.")
            print("-" * 40)
            continue

        source_filepath = os.path.join(locale_dir, source_filename)
        source_data = load_locale_file(source_filepath)

        if source_data is None:
            print(f"\n--- Skipping Feature: '{feature}' ---")
            print(f"Cannot proceed with feature '{feature}' due to invalid source file: {source_filename}")
            print("-" * 40)
            continue

        source_keys = get_all_keys(source_data)
        print(f"\n--- Auditing Feature: '{feature}' ---")
        print(f"Source Locale: {source_filename} ({len(source_keys)} keys found)")
        print("-" * 40)

        # Audit other languages for this specific feature
        for lang, target_filename in sorted(languages.items()):
            if lang == 'en': # Skip the source file itself
                continue

            target_filepath = os.path.join(locale_dir, target_filename)
            target_data = load_locale_file(target_filepath)

            if target_data is None:
                print(f"\nSkipping {target_filename} due to errors.")
                continue

            target_keys = get_all_keys(target_data)
            missing_keys = source_keys - target_keys
            extra_keys = target_keys - source_keys

            print(f"\nAuditing: {target_filename} ({len(target_keys)} keys found)")
            if missing_keys:
                print(f"  ❌ Missing Keys ({len(missing_keys)}):")
                for key in sorted(list(missing_keys)):
                    print(f"    - {key}")
            else:
                print("  ✅ No missing keys.")

            if extra_keys:
                print(f"  ⚠️ Extra Keys ({len(extra_keys)} - present in {target_filename} but not in {source_filename}):")
                for key in sorted(list(extra_keys)):
                    print(f"    - {key}")

            print("-" * 40)


if __name__ == "__main__":
    # --- Configuration ---
    # IMPORTANT: Replace 'path/to/your/locale/files' with the actual path
    # to your locale files. This can be an absolute path or relative to
    # where you run the script.
    LOCALE_DIRECTORY = './locales' # Example: Assuming your locales are in a 'locales' folder
    # SOURCE_LOCALE_FILENAME is no longer needed here as it's determined per feature

    # Create a dummy locales directory and files for testing if they don't exist
    if not os.path.exists(LOCALE_DIRECTORY):
        os.makedirs(LOCALE_DIRECTORY)
        print(f"Created dummy directory: {LOCALE_DIRECTORY}")

    # Dummy 'intro.en.yml'
    dummy_intro_en_content = {
        "intro_page": {
            "title": "Welcome",
            "description": "This is the introduction.",
            "next_button": "Continue"
        }
    }
    with open(os.path.join(LOCALE_DIRECTORY, 'intro.en.yml'), 'w', encoding='utf-8') as f:
        yaml.dump(dummy_intro_en_content, f, indent=2, default_flow_style=False)
    print(f"Created dummy file: {os.path.join(LOCALE_DIRECTORY, 'intro.en.yml')}")

    # Dummy 'intro.es.yml' (missing a key)
    dummy_intro_es_content = {
        "intro_page": {
            "title": "Bienvenido",
            # "description": "Esta es la introducción." # Intentionally missing
            "next_button": "Continuar"
        }
    }
    with open(os.path.join(LOCALE_DIRECTORY, 'intro.es.yml'), 'w', encoding='utf-8') as f:
        yaml.dump(dummy_intro_es_content, f, indent=2, default_flow_style=False)
    print(f"Created dummy file: {os.path.join(LOCALE_DIRECTORY, 'intro.es.yml')}")

    # Dummy 'candidates.en.yml'
    dummy_candidates_en_content = {
        "candidates_list": {
            "header": "Available Candidates",
            "filter_label": "Filter by:",
            "no_candidates": "No candidates found."
        }
    }
    with open(os.path.join(LOCALE_DIRECTORY, 'candidates.en.yml'), 'w', encoding='utf-8') as f:
        yaml.dump(dummy_candidates_en_content, f, indent=2, default_flow_style=False)
    print(f"Created dummy file: {os.path.join(LOCALE_DIRECTORY, 'candidates.en.yml')}")

    # Dummy 'candidates.fr.yml' (with an extra key)
    dummy_candidates_fr_content = {
        "candidates_list": {
            "header": "Candidats disponibles",
            "filter_label": "Filtrer par :",
            "no_candidates": "Aucun candidat trouvé."
        },
        "extra_candidate_key": "Clé supplémentaire pour les candidats." # Extra key
    }
    with open(os.path.join(LOCALE_DIRECTORY, 'candidates.fr.yml'), 'w', encoding='utf-8') as f:
        yaml.dump(dummy_candidates_fr_content, f, indent=2, default_flow_style=False)
    print(f"Created dummy file: {os.path.join(LOCALE_DIRECTORY, 'candidates.fr.yml')}")

    # Run the audit
    audit_locale_files(LOCALE_DIRECTORY)
