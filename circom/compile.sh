#!/usr/bin/env bash
#
# compile.sh — Compile Circom circuits for use with Picus.
#
# Usage:
#   ./compile.sh build <project>          # compile all .circom files in a project directory
#   ./compile.sh build-file <file.circom> # compile a single .circom file
#   ./compile.sh clean <project>          # remove all compiled outputs from a project directory
#
# Examples:
#   ./compile.sh build circomlib-cff5ab6
#   ./compile.sh build-file circomlib-cff5ab6/AND@gates.circom
#   ./compile.sh clean circomlib-cff5ab6
#
# Compilation flags:
#   --O0    Disables all circom optimizations. This is required by Picus — the
#           analyzer operates on the raw constraint structure, and compiler
#           optimizations can alter or remove constraints in ways that change
#           the under-constrained analysis results.
#   --r1cs  Outputs the R1CS binary file (constraint system).
#   --sym   Outputs the symbol map (signal ID to name mapping).
#
# Requirements:
#   - circom 2.0+ on PATH (https://docs.circom.io/)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIBS_DIR="$SCRIPT_DIR/libs"

usage() {
    echo "Usage:"
    echo "  $0 build <project>            Compile all circuits in a project directory"
    echo "  $0 build-file <file.circom>   Compile a single circuit file"
    echo "  $0 clean <project>            Remove compiled outputs from a project directory"
    echo
    echo "Projects: $(ls -d "$SCRIPT_DIR"/*/ 2>/dev/null | xargs -I{} basename {} | grep -v libs | tr '\n' ' ')"
    exit 1
}

check_circom() {
    if ! command -v circom &>/dev/null; then
        echo "error: circom not found on PATH"
        echo "Install from: https://docs.circom.io/"
        exit 1
    fi
}

compile_one() {
    local f="$1"
    local NAME=$(basename "$f" .circom)
    local OUTPUT_DIR=$(dirname "$f")

    if circom "$f" --r1cs --sym --O0 --output "$OUTPUT_DIR" -l "$LIBS_DIR" 2>/dev/null | grep -q "Everything went okay"; then
        echo "  ✓ $NAME"
        return 0
    else
        echo "  ✗ $NAME"
        return 1
    fi
}

cmd_build() {
    local PROJECT="$1"
    local DIR="$SCRIPT_DIR/$PROJECT"

    if [[ ! -d "$DIR" ]]; then
        echo "error: project directory not found: $PROJECT"
        exit 1
    fi

    check_circom
    echo "circom: $(circom --version)"
    echo "project: $PROJECT"
    echo

    local COMPILED=0
    local FAILED=0
    local SKIPPED=0

    for f in "$DIR"/*.circom; do
        [[ -f "$f" ]] || continue
        local NAME=$(basename "$f" .circom)

        if [[ -f "$DIR/$NAME.r1cs" ]]; then
            SKIPPED=$((SKIPPED + 1))
            continue
        fi

        if compile_one "$f"; then
            COMPILED=$((COMPILED + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    done

    echo
    echo "Compiled: $COMPILED  Skipped: $SKIPPED  Failed: $FAILED"
}

cmd_build_file() {
    local FILE="$1"

    # Resolve relative to script dir if not absolute
    if [[ ! "$FILE" = /* ]]; then
        FILE="$SCRIPT_DIR/$FILE"
    fi

    if [[ ! -f "$FILE" ]]; then
        echo "error: file not found: $1"
        exit 1
    fi

    check_circom
    echo "circom: $(circom --version)"
    echo
    compile_one "$FILE"
}

cmd_clean() {
    local PROJECT="$1"
    local DIR="$SCRIPT_DIR/$PROJECT"

    if [[ ! -d "$DIR" ]]; then
        echo "error: project directory not found: $PROJECT"
        exit 1
    fi

    local COUNT=0
    for ext in r1cs sym json wat wasm; do
        for f in "$DIR"/*."$ext"; do
            [[ -f "$f" ]] || continue
            rm "$f"
            COUNT=$((COUNT + 1))
        done
    done

    echo "Cleaned $COUNT files from $PROJECT"
}

# ── Main ──

if [[ $# -lt 2 ]]; then
    usage
fi

COMMAND="$1"
TARGET="$2"

case "$COMMAND" in
    build)
        cmd_build "$TARGET"
        ;;
    build-file)
        cmd_build_file "$TARGET"
        ;;
    clean)
        cmd_clean "$TARGET"
        ;;
    *)
        echo "error: unknown command '$COMMAND'"
        usage
        ;;
esac
