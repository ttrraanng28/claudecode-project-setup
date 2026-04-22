#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INDEX_FILE="$ROOT_DIR/.claude/docs/index.md"
DOCS_DIR="$ROOT_DIR/.claude/docs"

if [[ ! -d "$DOCS_DIR" || ! -f "$INDEX_FILE" ]]; then
  exit 0
fi

python3 - "$DOCS_DIR" "$INDEX_FILE" <<'PY'
import sys
from pathlib import Path

docs_dir = Path(sys.argv[1])
index_file = Path(sys.argv[2])
start_marker = "<!-- AUTO_DOC_LIST_START -->"
end_marker = "<!-- AUTO_DOC_LIST_END -->"

doc_files = sorted(
    p.name for p in docs_dir.glob("*.md") if p.name.lower() != "index.md"
)

lines = [f"- [{name}]({name})" for name in doc_files]
block = "\n".join([start_marker, *lines, end_marker])

content = index_file.read_text(encoding="utf-8")

if start_marker in content and end_marker in content:
    before, rest = content.split(start_marker, 1)
    _, after = rest.split(end_marker, 1)
    updated = f"{before}{block}{after}"
else:
    append = "\n## Available Docs (Auto-generated)\n\n" + block + "\n"
    if not content.endswith("\n"):
        content += "\n"
    updated = content + append

if updated != content:
    index_file.write_text(updated, encoding="utf-8")
PY

echo '{ "success": true }'
