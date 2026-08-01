#!/usr/bin/env bash
# Bootstrap Idris2 + pack inside WSL (non-interactive).
set -euo pipefail
export PATH="${HOME}/.local/bin:${PATH}"

echo "user=$(whoami) HOME=${HOME}"

# Prerequisites
if ! command -v scheme >/dev/null 2>&1 && ! command -v chezscheme >/dev/null 2>&1; then
  echo "Installing chezscheme..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq chezscheme libgmp-dev git make gcc curl
fi

cd /tmp
rm -f install-pack.bash
curl -fsSL https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash -o install-pack.bash

# Replace interactive scheme prompt with fixed binary
python3 - <<'PY'
from pathlib import Path
p = Path("install-pack.bash")
t = p.read_text()
# Replace the read prompt line
import re
t2 = re.sub(
    r'read -r -p "Enter the name of your chez-scheme or racket binary \[\$DETECTED_SCHEME\]: " SCHEME\nSCHEME=\$\{SCHEME:-\$DETECTED_SCHEME\}',
    'SCHEME=chezscheme\necho "Using fixed SCHEME=chezscheme"',
    t,
)
if t2 == t:
    # fallback: simpler replace
    t2 = t.replace(
        'read -r -p "Enter the name of your chez-scheme or racket binary [$DETECTED_SCHEME]: " SCHEME',
        'SCHEME=chezscheme',
    )
p.write_text(t2)
print("patched install-pack.bash")
PY

# Clean partial state for this user
rm -rf "${HOME}/.local/state/pack" "${HOME}/.cache/pack" 2>/dev/null || true
mkdir -p "${HOME}/.local/bin"

bash install-pack.bash
echo "PACK_INSTALL_EXIT=$?"

export PATH="${HOME}/.local/bin:${PATH}"
echo "=== verify ==="
command -v idris2
command -v pack
idris2 --version
pack info | head -30
