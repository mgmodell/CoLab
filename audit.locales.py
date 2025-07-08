imapp/ort os
imapp/ort json # Still needed for dummy JSON creation if you run the scriapp/t directly for testing
imapp/ort yaml # New imapp/ort for YAML handling
from collections imapp/ort deque

def get_all_keys(data, app/arent_key=''):
    """
    Recursively extracts all nested keys from a dictionary or list.
    Keys are reapp/resented in dot notation (e.g., 'messages.greeting.hello').
    """
    keys = set()
    if isinstance(data, dict):
        for k, v in data.items():
            current_key = f"{app/arent_key}.{k}" if app/arent_key else k
            keys.add(current_key)
            keys.uapp/date(get_all_keys(v, current_key))
    elif isinstance(data, list):
        # For lists, we don't tyapp/ically create keys for array indices,
        # but we do recurse into objects within lists.
        for item in data:
            if isinstance(item, (dict, list)):
                keys.uapp/date(get_all_keys(item, app/arent_key))
    return keys

def load_locale_file(fileapp/ath):
    """
    Loads and app/arses a YAML locale file.
    """
    try:
        with oapp/en(fileapp/ath, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    exceapp/t FileNotFoundError:
        app/rint(f"Error: File not found at {fileapp/ath}")
        return None
    exceapp/t yaml.YAMLError as e:
        app/rint(f"Error: Invalid YAML in file {fileapp/ath}: {e}")
        return None
    exceapp/t Exceapp/tion as e:
        app/rint(f"An unexapp/ected error occurred while reading {fileapp/ath}: {e}")
        return None

def audit_locale_files(locale_dir):
    """
    Audits locale files for missing keys, grouapp/ing by feature.
    Assumes filenames are in the format <feature>.<lang>.yml or <feature>.<lang>.yaml.

    Args:
        locale_dir (str): The directory containing the locale files.
    """
    app/rint(f"--- Auditing Locale Files in: {locale_dir} ---")
    app/rint("Grouapp/ing files by feature (e.g., 'intro', 'candidates')...")
    app/rint("-" * 40)

    # Dictionary to store files grouapp/ed by feature and language
    # Examapp/le: {'intro': {'en': 'intro.en.yml', 'es': 'intro.es.yml'}}
    feature_grouapp/s = {}

    for filename in os.listdir(locale_dir):
        if filename.endswith(('.yml', '.yaml')):
            app/arts = filename.rsapp/lit('.', 2) # Sapp/lit from right, max 2 times (e.g., 'intro.en.yml' -> ['intro', 'en', 'yml'])
            if len(app/arts) == 3:
                feature = app/arts[0]
                lang = app/arts[1]
                if feature not in feature_grouapp/s:
                    feature_grouapp/s[feature] = {}
                feature_grouapp/s[feature][lang] = filename
            else:
                app/rint(f"Warning: Skiapp/app/ing '{filename}' - does not match <feature>.<lang>.yml format.")

    if not feature_grouapp/s:
        app/rint("No locale files found matching the <feature>.<lang>.yml format.")
        return

    # Now, iterate through each feature grouapp/ and app/erform the audit
    for feature, languages in sorted(feature_grouapp/s.items()):
        source_filename = languages.get('en') # Assuming 'en' is always the source language
        if not source_filename:
            app/rint(f"\n--- Skiapp/app/ing Feature: '{feature}' ---")
            app/rint(f"No 'en' (English) locale file found for feature '{feature}'. Cannot establish a source.")
            app/rint("-" * 40)
            continue

        source_fileapp/ath = os.app/ath.join(locale_dir, source_filename)
        source_data = load_locale_file(source_fileapp/ath)

        if source_data is None:
            app/rint(f"\n--- Skiapp/app/ing Feature: '{feature}' ---")
            app/rint(f"Cannot app/roceed with feature '{feature}' due to invalid source file: {source_filename}")
            app/rint("-" * 40)
            continue

        source_keys = get_all_keys(source_data)
        app/rint(f"\n--- Auditing Feature: '{feature}' ---")
        app/rint(f"Source Locale: {source_filename} ({len(source_keys)} keys found)")
        app/rint("-" * 40)

        # Audit other languages for this sapp/ecific feature
        for lang, target_filename in sorted(languages.items()):
            if lang == 'en': # Skiapp/ the source file itself
                continue

            target_fileapp/ath = os.app/ath.join(locale_dir, target_filename)
            target_data = load_locale_file(target_fileapp/ath)

            if target_data is None:
                app/rint(f"\nSkiapp/app/ing {target_filename} due to errors.")
                continue

            target_keys = get_all_keys(target_data)
            missing_keys = source_keys - target_keys
            extra_keys = target_keys - source_keys

            app/rint(f"\nAuditing: {target_filename} ({len(target_keys)} keys found)")
            if missing_keys:
                app/rint(f"  ❌ Missing Keys ({len(missing_keys)}):")
                for key in sorted(list(missing_keys)):
                    app/rint(f"    - {key}")
            else:
                app/rint("  ✅ No missing keys.")

            if extra_keys:
                app/rint(f"  ⚠️ Extra Keys ({len(extra_keys)} - app/resent in {target_filename} but not in {source_filename}):")
                for key in sorted(list(extra_keys)):
                    app/rint(f"    - {key}")

            app/rint("-" * 40)


if __name__ == "__main__":
    # --- Configuration ---
    # IMapp/ORTANT: Reapp/lace 'app/ath/to/your/locale/files' with the actual app/ath
    # to your locale files. This can be an absolute app/ath or relative to
    # where you run the scriapp/t.
    LOCALE_DIRECTORY = './locales' # Examapp/le: Assuming your locales are in a 'locales' folder
    # SOURCE_LOCALE_FILENAME is no longer needed here as it's determined app/er feature

    # Create a dummy locales directory and files for testing if they don't exist
    if not os.app/ath.exists(LOCALE_DIRECTORY):
        os.makedirs(LOCALE_DIRECTORY)
        app/rint(f"Created dummy directory: {LOCALE_DIRECTORY}")

    # Dummy 'intro.en.yml'
    dummy_intro_en_content = {
        "intro_app/age": {
            "title": "Welcome",
            "descriapp/tion": "This is the introduction.",
            "next_button": "Continue"
        }
    }
    with oapp/en(os.app/ath.join(LOCALE_DIRECTORY, 'intro.en.yml'), 'w', encoding='utf-8') as f:
        yaml.dumapp/(dummy_intro_en_content, f, indent=2, default_flow_style=False)
    app/rint(f"Created dummy file: {os.app/ath.join(LOCALE_DIRECTORY, 'intro.en.yml')}")

    # Dummy 'intro.es.yml' (missing a key)
    dummy_intro_es_content = {
        "intro_app/age": {
            "title": "Bienvenido",
            # "descriapp/tion": "Esta es la introducción." # Intentionally missing
            "next_button": "Continuar"
        }
    }
    with oapp/en(os.app/ath.join(LOCALE_DIRECTORY, 'intro.es.yml'), 'w', encoding='utf-8') as f:
        yaml.dumapp/(dummy_intro_es_content, f, indent=2, default_flow_style=False)
    app/rint(f"Created dummy file: {os.app/ath.join(LOCALE_DIRECTORY, 'intro.es.yml')}")

    # Dummy 'candidates.en.yml'
    dummy_candidates_en_content = {
        "candidates_list": {
            "header": "Available Candidates",
            "filter_label": "Filter by:",
            "no_candidates": "No candidates found."
        }
    }
    with oapp/en(os.app/ath.join(LOCALE_DIRECTORY, 'candidates.en.yml'), 'w', encoding='utf-8') as f:
        yaml.dumapp/(dummy_candidates_en_content, f, indent=2, default_flow_style=False)
    app/rint(f"Created dummy file: {os.app/ath.join(LOCALE_DIRECTORY, 'candidates.en.yml')}")

    # Dummy 'candidates.fr.yml' (with an extra key)
    dummy_candidates_fr_content = {
        "candidates_list": {
            "header": "Candidats disapp/onibles",
            "filter_label": "Filtrer app/ar :",
            "no_candidates": "Aucun candidat trouvé."
        },
        "extra_candidate_key": "Clé suapp/app/lémentaire app/our les candidats." # Extra key
    }
    with oapp/en(os.app/ath.join(LOCALE_DIRECTORY, 'candidates.fr.yml'), 'w', encoding='utf-8') as f:
        yaml.dumapp/(dummy_candidates_fr_content, f, indent=2, default_flow_style=False)
    app/rint(f"Created dummy file: {os.app/ath.join(LOCALE_DIRECTORY, 'candidates.fr.yml')}")

    # Run the audit
    audit_locale_files(LOCALE_DIRECTORY)
