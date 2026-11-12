#!/usr/bin/env python3
"""Configure the generated Flutter Android project for Firebase.

This script is intentionally idempotent: running it more than once must not
insert duplicate Gradle plugins or damage the generated Gradle files.
"""
from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ANDROID = ROOT / "android"
CONFIG_SOURCE = ROOT / "android_overlay" / "google-services.json"
PLUGIN_VERSION = "4.5.0"
EXPECTED_PACKAGE = "com.shaghelmokh.shaghel_mokh"
MIN_ANDROID_SDK = 24  # Firebase Android SDK 35 / firebase_core 5.x requirement.
PLUGIN_ID = "com.google.gms.google-services"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _write(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8", newline="\n")


def _find_gradle(base: Path, names: tuple[str, ...]) -> Path | None:
    return next((base / name for name in names if (base / name).is_file()), None)


def _insert_into_plugins_block(text: str, line: str) -> str:
    match = re.search(r"(?m)^\s*plugins\s*\{", text)
    if not match:
        raise RuntimeError("Could not find a Gradle plugins { } block")
    opening = text.find("{", match.start())
    depth = 0
    closing = None
    for index in range(opening, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                closing = index
                break
    if closing is None:
        raise RuntimeError("Unclosed Gradle plugins block")
    return text[:closing] + "\n" + line + "\n" + text[closing:]

def _ensure_plugin_repositories(text: str, is_kts: bool) -> str:
    """Ensure pluginManagement can resolve Google and Maven Central plugins."""
    match = re.search(r"(?ms)^\s*pluginManagement\s*\{(.*?)^\}", text)
    if not match:
        return text
    block = match.group(1)
    repos_match = re.search(r"(?ms)^\s*repositories\s*\{(.*?)^\s*\}", block)
    if not repos_match:
        repo_lines = "\n        google()\n        mavenCentral()\n        gradlePluginPortal()\n    "
        updated_block = block + "\n    repositories {" + repo_lines + "}\n"
    else:
        repos = repos_match.group(1)
        additions = []
        if not re.search(r"(?m)^\s*google\s*\(\s*\)", repos):
            additions.append("        google()")
        if not re.search(r"(?m)^\s*mavenCentral\s*\(\s*\)", repos):
            additions.append("        mavenCentral()")
        if not re.search(r"(?m)^\s*gradlePluginPortal\s*\(\s*\)", repos):
            additions.append("        gradlePluginPortal()")
        if additions:
            repos_updated = repos + "\n" + "\n".join(additions) + "\n    "
            block = block[: repos_match.start(1)] + repos_updated + block[repos_match.end(1) :]
        updated_block = block
    return text[: match.start(1)] + updated_block + text[match.end(1) :]


def _ensure_gradle_plugin(settings: Path, app_gradle: Path) -> None:
    settings_text = _read(settings)
    app_text = _read(app_gradle)
    is_kts_settings = settings.name.endswith(".kts")
    is_kts_app = app_gradle.name.endswith(".kts")

    settings_text = _ensure_plugin_repositories(settings_text, is_kts_settings)
    if PLUGIN_ID not in settings_text:
        if is_kts_settings:
            declaration = f'    id("{PLUGIN_ID}") version "{PLUGIN_VERSION}" apply false'
        else:
            declaration = f"    id '{PLUGIN_ID}' version '{PLUGIN_VERSION}' apply false"
        settings_text = _insert_into_plugins_block(settings_text, declaration)

    if PLUGIN_ID not in app_text:
        if re.search(r"(?m)^\s*plugins\s*\{", app_text):
            if is_kts_app:
                declaration = f'    id("{PLUGIN_ID}")'
                android_plugin = r'(?m)^\s*id\("com\.android\.application"\)\s*$'
            else:
                declaration = f"    id '{PLUGIN_ID}'"
                android_plugin = r"(?m)^\s*id ['\"]com\.android\.application['\"]\s*$"
            android_match = re.search(android_plugin, app_text)
            if android_match:
                app_text = app_text[:android_match.end()] + "\n" + declaration + app_text[android_match.end():]
            else:
                app_text = _insert_into_plugins_block(app_text, declaration)
        else:
            if is_kts_app:
                app_text += f'\napply(plugin = "{PLUGIN_ID}")\n'
            else:
                app_text += f"\napply plugin: '{PLUGIN_ID}'\n"


    _write(settings, settings_text)
    _write(app_gradle, app_text)


def _ensure_default_config(app_text: str, is_kts: bool) -> str:
    """Set package id and minSdk safely inside the app's defaultConfig block."""
    match = re.search(r"(?m)^\s*defaultConfig\s*\{", app_text)
    if not match:
        raise RuntimeError("Could not find defaultConfig { } in android/app Gradle file")

    # Find the matching closing brace using a small brace scanner so nested
    # Gradle blocks do not cause a partial replacement.
    opening = app_text.find("{", match.start())
    depth = 0
    closing = None
    for index in range(opening, len(app_text)):
        char = app_text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                closing = index
                break
    if closing is None:
        raise RuntimeError("Unclosed defaultConfig block in android/app Gradle file")

    block = app_text[opening + 1 : closing]
    line_start = app_text.rfind("\n", 0, match.start()) + 1
    line_end = app_text.find("\n", line_start)
    if line_end < 0:
        line_end = len(app_text)
    declaration_line = app_text[line_start:line_end]
    block_indent = len(declaration_line) - len(declaration_line.lstrip())
    inner_indent = " " * (block_indent + 4)
    if is_kts:
        app_id_pattern = r'(?m)^\s*applicationId\s*=\s*"([^"]+)"'
        app_id_line = f'{inner_indent}applicationId = "{EXPECTED_PACKAGE}"'
        min_pattern = r"(?m)^\s*minSdk\s*=\s*[^\n]+"
        min_line = f"{inner_indent}minSdk = maxOf(flutter.minSdkVersion, {MIN_ANDROID_SDK})"
    else:
        app_id_pattern = r"(?m)^\s*applicationId\s+['\"]([^'\"]+)['\"]"
        app_id_line = f"{inner_indent}applicationId '{EXPECTED_PACKAGE}'"
        min_pattern = r"(?m)^\s*minSdkVersion\s+[^\n]+"
        min_line = f"{inner_indent}minSdkVersion Math.max(flutter.minSdkVersion, {MIN_ANDROID_SDK})"

    app_id_match = re.search(app_id_pattern, block)
    if app_id_match:
        current_id = app_id_match.group(1)
        if current_id != EXPECTED_PACKAGE:
            raise ValueError(
                f"Generated Android applicationId mismatch: expected {EXPECTED_PACKAGE}, got {current_id}"
            )
    else:
        block = "\n" + app_id_line + block

    if re.search(min_pattern, block):
        block = re.sub(min_pattern, min_line, block, count=1)
    else:
        block = "\n" + min_line + block

    return app_text[: opening + 1] + block + app_text[closing:]



def _configure_gradle_memory(android_dir: Path) -> None:
    """Keep Gradle memory use predictable on standard GitHub-hosted runners."""
    properties = android_dir / "gradle.properties"
    lines = properties.read_text(encoding="utf-8").splitlines() if properties.exists() else []
    values = {
        "org.gradle.jvmargs": "-Xmx4G -XX:MaxMetaspaceSize=1G -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8",
        "org.gradle.workers.max": "2",
        "org.gradle.parallel": "false",
        "android.useAndroidX": "true",
    }
    for key, value in values.items():
        pattern = re.compile(rf"^\s*{re.escape(key)}\s*=")
        for index, line in enumerate(lines):
            if pattern.search(line):
                lines[index] = f"{key}={value}"
                break
        else:
            lines.append(f"{key}={value}")
    _write(properties, "\n".join(lines).rstrip() + "\n")

def validate_firebase_config() -> dict:
    if not CONFIG_SOURCE.is_file():
        raise FileNotFoundError(f"Missing Firebase config: {CONFIG_SOURCE}")
    config = json.loads(_read(CONFIG_SOURCE))
    project_info = config.get("project_info") or {}
    project_id = project_info.get("project_id")
    sender_id = str(project_info.get("project_number", ""))
    clients = config.get("client", [])
    matching = [
        c for c in clients
        if c.get("client_info", {}).get("android_client_info", {}).get("package_name") == EXPECTED_PACKAGE
    ]
    if not matching:
        found = sorted({
            str(c.get("client_info", {}).get("android_client_info", {}).get("package_name"))
            for c in clients
        })
        raise ValueError(f"Firebase package mismatch. Expected {EXPECTED_PACKAGE}, got {found}")
    client_info = matching[0].get("client_info") or {}
    app_id = client_info.get("mobilesdk_app_id")
    api_keys = matching[0].get("api_key") or []
    api_key = api_keys[0].get("current_key") if api_keys else None
    if not project_id or not sender_id or not app_id or not api_key:
        raise ValueError("Firebase config is missing project_id, project_number, app_id, or API key")
    return config


def main() -> None:
    config = validate_firebase_config()
    settings = _find_gradle(ANDROID, ("settings.gradle.kts", "settings.gradle"))
    app_gradle = _find_gradle(ANDROID / "app", ("build.gradle.kts", "build.gradle"))
    if settings is None or app_gradle is None:
        raise RuntimeError(
            "Generated Android Gradle files were not found. Run 'flutter create --platforms=android .' first."
        )

    app_dir = ANDROID / "app"
    app_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(CONFIG_SOURCE, app_dir / "google-services.json")

    _ensure_gradle_plugin(settings, app_gradle)
    app_text = _read(app_gradle)
    app_text = _ensure_default_config(app_text, app_gradle.name.endswith(".kts"))
    _write(app_gradle, app_text)
    _configure_gradle_memory(ANDROID)

    # Fail fast before Gradle if the generated config does not line up.
    if EXPECTED_PACKAGE not in app_text:
        raise RuntimeError("Expected applicationId was not found after Gradle configuration")
    if PLUGIN_ID not in _read(app_gradle) or PLUGIN_ID not in _read(settings):
        raise RuntimeError("Google Services Gradle plugin was not applied correctly")

    print(f"Firebase project validated: {config['project_info']['project_id']}")
    print(f"Android applicationId: {EXPECTED_PACKAGE}")
    print(f"Minimum Android SDK: {MIN_ANDROID_SDK}")
    print(f"Google Services Gradle plugin: {PLUGIN_VERSION}")
    print(f"Copied Firebase configuration to {app_dir / 'google-services.json'}")


if __name__ == "__main__":
    main()
