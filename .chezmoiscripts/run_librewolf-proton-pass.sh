#!/bin/bash
set -euo pipefail

# Preinstall the Proton Pass extension in LibreWolf.
#
# LibreWolf reads a single policies file: the packaged
# /usr/lib/librewolf/distribution/policies.json, which already installs
# uBlock Origin through ExtensionSettings. Merge our entry into that file
# instead of writing a separate one, so LibreWolf's own policies are kept.
#
# This runs on every `chezmoi apply` but returns immediately, without asking
# for sudo, while the entry is present. A LibreWolf upgrade restores the
# packaged file, and the entry is then re-added on the next apply.

policies=/usr/lib/librewolf/distribution/policies.json
extension_id=78272b6fa58f4a1abaac99321d503a20@proton.me

[[ -r $policies ]] || exit 0 # LibreWolf is not installed yet
grep -q "\"$extension_id\"" "$policies" && exit 0

merged=$(mktemp)
trap 'rm -f "$merged"' EXIT

python3 - "$policies" "$merged" "$extension_id" <<'PY'
import json
import sys

source, destination, extension_id = sys.argv[1:4]

with open(source, encoding="utf-8") as file:
    policies = json.load(file)

# "normal_installed" installs the extension on first start but still lets the
# user disable or remove it. Use "force_installed" to make that impossible.
policies.setdefault("policies", {}).setdefault("ExtensionSettings", {})[extension_id] = {
    "installation_mode": "normal_installed",
    "install_url": "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi",
}

with open(destination, "w", encoding="utf-8") as file:
    json.dump(policies, file, indent=4)
    file.write("\n")
PY

sudo install -m 644 "$merged" "$policies"
