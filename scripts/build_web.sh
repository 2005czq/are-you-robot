#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

"$SCRIPT_DIR/flutterw" build web "$@"

echo
echo "Build complete: $PROJECT_ROOT/build/web"
echo "Preview with: python3 -m http.server 7357 --directory build/web"
