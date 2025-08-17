#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────
#  Universal Rice Automator
# ──────────────────────────────

# Your GitHub repo (change if you fork/rename later)
REPO="dobbyncicode/Minimal-Arch-Setup"
BRANCH="main"

# Temp dir for downloaded scripts
TMPDIR="$(mktemp -d)"

echo "🌾 Pulling rice scripts from GitHub..."

# Fetch list of all files in repo, filter only `*-rice.sh`
curl -s "https://api.github.com/repos/$REPO/git/trees/$BRANCH?recursive=1" \
  | grep -oP '"path": "\K.*(?=")' \
  | grep '\-rice\.sh$' > "$TMPDIR/rice-list.txt"

if [[ ! -s "$TMPDIR/rice-list.txt" ]]; then
    echo "❌ No rice scripts found in repo."
    exit 1
fi

# Download each script and execute
while IFS= read -r script_path; do
    script_name="$(basename "$script_path")"
    script_url="https://raw.githubusercontent.com/$REPO/$BRANCH/$script_path"

    echo "→ Fetching $script_name..."
    curl -fsSL "$script_url" -o "$TMPDIR/$script_name"

    echo "⚡ Running $script_name..."
    bash "$TMPDIR/$script_name"

    echo "✔ Finished $script_name"
    echo
done < "$TMPDIR/rice-list.txt"

echo "🎉 All rice modules applied successfully!"

# Cleanup
rm -rf "$TMPDIR"
