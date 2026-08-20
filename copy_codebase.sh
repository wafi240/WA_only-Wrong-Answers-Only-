#!/bin/bash
# copy_codebase.sh — copy WAOnly source to clipboard via wl-copy
# Usage: ./copy_codebase.sh [--no-tests] [--no-assets] [--save file.md]

set -e

# ── parse args ─────────────────────────────────────────────────
INCLUDE_TESTS=1
INCLUDE_ASSETS=1
SAVE_FILE=""

for arg in "$@"; do
    case $arg in
        --no-tests)  INCLUDE_TESTS=0 ;;
        --no-assets) INCLUDE_ASSETS=0 ;;
        --save)      shift; SAVE_FILE="$1" ;;
        --save=*)    SAVE_FILE="${arg#--save=}" ;;
        --help)
            echo "Usage: $0 [--no-tests] [--no-assets] [--save file.md]"
            exit 0 ;;
    esac
done

# ── check dependencies ─────────────────────────────────────────
if ! command -v wl-copy &>/dev/null; then
    echo "✗ wl-copy not found"
    echo "  Install: sudo pacman -S wl-clipboard"
    exit 1
fi

# ── what to include ────────────────────────────────────────────
# Source dirs → (dir, extensions...)
declare -A DIR_EXTENSIONS=(
    ["src"]="cpp h hpp"
    ["DS"]="hpp"
    ["assets/checker"]="cpp h hpp"
)

# Individual files always included
LONE_FILES=(
    "Makefile"
    "README.md"
    "roadmap.txt"
    "verify_all.sh"
    "verify.sh"
)

# Data files (small, useful for context)
DATA_FILES=(
    "assets/users.dat"
    "assets/problems.dat"
    "assets/contests.dat"
    "assets/submissions.dat"
)

# Optional: tests
[ $INCLUDE_TESTS -eq 1 ] && DIR_EXTENSIONS["tests"]="cpp h"

# Optional: asset text files
if [ $INCLUDE_ASSETS -eq 1 ]; then
    DIR_EXTENSIONS["assets/problems"]="txt"
    DIR_EXTENSIONS["assets/solutions"]="cpp"
    DIR_EXTENSIONS["assets/testcases"]="in out"
fi

# ── always skip these ──────────────────────────────────────────
SKIP_NAMES=(
    "*.o"
    "waonly"
    "run_tests"
    "test_p1001"
    "prompt.txt"       # too large, meta
)

# ── helper: check if file should be skipped ────────────────────
should_skip() {
    local f="$1"
    local base
    base=$(basename "$f")
    for pat in "${SKIP_NAMES[@]}"; do
        # shellcheck disable=SC2254
        case "$base" in
            $pat) return 0 ;;
        esac
    done
    return 1
}

# ── helper: print a file with header ──────────────────────────
print_file() {
    local f="$1"
    local rel="${f#./}"
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    printf  "║  %-56s  ║\n" "$rel"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo '```'
    cat "$f"
    echo ""
    echo '```'
}

# ── build output ───────────────────────────────────────────────
TMPFILE=$(mktemp /tmp/waonly_dump_XXXXXX.md)
trap 'rm -f "$TMPFILE"' EXIT

{
    # ── header ────────────────────────────────────────────────
    echo "# WAOnly — Full Codebase Dump"
    echo "> Generated : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "> Root      : $(pwd)"
    echo "> Options   : tests=$INCLUDE_TESTS  assets=$INCLUDE_ASSETS"
    echo ""

    # ── project tree ──────────────────────────────────────────
    echo "## Project Structure"
    echo '```'
    if command -v tree &>/dev/null; then
        tree -I '*.o|waonly|run_tests|test_p1001|prompt.txt|.git|__pycache__' \
             --noreport 2>/dev/null || find . -not -path '*/.git/*' | sort
    else
        find . -not -path '*/.git/*' \
               -not -name '*.o' \
               -not -name 'waonly' \
               -not -name 'run_tests' \
               -not -name 'test_p1001' \
               -not -name 'prompt.txt' \
               | sort
    fi
    echo '```'
    echo ""

    # ── lone files ────────────────────────────────────────────
    echo "## Root Files"
    for f in "${LONE_FILES[@]}"; do
        [ -f "$f" ] || continue
        print_file "$f"
    done

    # ── data files ────────────────────────────────────────────
    echo ""
    echo "## Data Files"
    for f in "${DATA_FILES[@]}"; do
        [ -f "$f" ] || continue
        print_file "$f"
    done

    # ── source directories ────────────────────────────────────
    for dir in "src" "DS" "assets/checker" "assets/problems" \
               "assets/solutions" "assets/testcases" "tests"; do

        [ -d "$dir" ] || continue
        exts="${DIR_EXTENSIONS[$dir]}"
        [ -z "$exts" ] && continue

        # build find -name expression
        name_expr=""
        for ext in $exts; do
            if [ -z "$name_expr" ]; then
                name_expr="-name *.${ext}"
            else
                name_expr="${name_expr} -o -name *.${ext}"
            fi
        done

        echo ""
        echo "## Directory: $dir"

        # collect files, sorted
        while IFS= read -r f; do
            should_skip "$f" && continue
            print_file "$f"
        done < <(eval "find \"$dir\" -type f \( $name_expr \)" 2>/dev/null | sort)

    done

    # ── footer ────────────────────────────────────────────────
    echo ""
    echo "---"
    echo "_End of WAOnly codebase dump_"

} > "$TMPFILE"

# ── stats ──────────────────────────────────────────────────────
TOTAL_LINES=$(wc -l < "$TMPFILE")
TOTAL_BYTES=$(wc -c < "$TMPFILE")
TOTAL_KB=$(( TOTAL_BYTES / 1024 ))
FILE_COUNT=$(grep -c "^╔══" "$TMPFILE" || true)

# ── copy to clipboard ──────────────────────────────────────────
wl-copy < "$TMPFILE"

# ── optional save ──────────────────────────────────────────────
if [ -n "$SAVE_FILE" ]; then
    cp "$TMPFILE" "$SAVE_FILE"
    echo "✓ Saved to: $SAVE_FILE"
fi

# ── report ─────────────────────────────────────────────────────
echo ""
echo "✓ Codebase copied to clipboard"
echo "──────────────────────────────"
printf "  Files  : %d\n" "$FILE_COUNT"
printf "  Lines  : %d\n" "$TOTAL_LINES"
printf "  Size   : %d KB (%d bytes)\n" "$TOTAL_KB" "$TOTAL_BYTES"
echo ""

# warn if very large
if [ "$TOTAL_KB" -gt 500 ]; then
    echo "⚠ Warning: dump is ${TOTAL_KB}KB — may exceed LLM context limits"
    echo "  Try: $0 --no-tests --no-assets"
    echo ""
fi

echo "Paste with: Ctrl+Shift+V  or  middle-click"
