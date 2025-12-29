#!/bin/bash

# Quality Checks Script
# Usage: ./scripts/quality-checks.sh [--staged]
#   --staged    Run on staged files only (for pre-commit hooks)
#   (default)   Run on all files (for CI)

set -e

# Parse arguments
STAGED_MODE=false
if [[ "$1" == "--staged" ]]; then
    STAGED_MODE=true
fi

# Get Swift files based on mode
if $STAGED_MODE; then
    # Staged files only (Added, Copied, Modified - not deleted)
    SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)
    MODE_DESC="staged"
else
    # All Swift files in the project
    SWIFT_FILES=$(find ADishADay -name "*.swift" -type f)
    MODE_DESC="all"
fi

# Track if any check fails
FAILED=0

echo "Running quality checks ($MODE_DESC files)..."
echo ""

# =============================================================================
# 1. swift-format (formatting)
# =============================================================================
SWIFT_FORMAT="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"

if [ -n "$SWIFT_FILES" ]; then
    if [ ! -x "$SWIFT_FORMAT" ]; then
        echo "Warning: swift-format not found, skipping formatting"
    else
        echo "Formatting Swift files..."
        echo "$SWIFT_FILES" | while read -r file; do
            if [ -f "$file" ]; then
                "$SWIFT_FORMAT" format --in-place "$file"
                # Only re-stage in staged mode
                if $STAGED_MODE; then
                    git add "$file"
                fi
            fi
        done
        echo "Formatted"
    fi
else
    echo "No Swift files to format"
fi

# =============================================================================
# 2. SwiftLint (linting)
# =============================================================================
if [ -n "$SWIFT_FILES" ]; then
    if command -v swiftlint &> /dev/null; then
        echo "Linting Swift files..."
        # Auto-fix what we can
        echo "$SWIFT_FILES" | xargs swiftlint --fix --quiet
        # Re-stage fixed files in staged mode
        if $STAGED_MODE; then
            echo "$SWIFT_FILES" | while read -r file; do
                if [ -f "$file" ]; then
                    git add "$file"
                fi
            done
        fi
        # Check for remaining errors
        if ! echo "$SWIFT_FILES" | xargs swiftlint lint --quiet --strict; then
            echo "SwiftLint found errors"
            FAILED=1
        else
            echo "Lint passed"
        fi
    else
        echo "Warning: swiftlint not found, skipping lint (install: brew install swiftlint)"
    fi
else
    echo "No Swift files to lint"
fi

# =============================================================================
# 3. typos (spellcheck) - always runs on all files
# =============================================================================
if command -v typos &> /dev/null; then
    echo "Checking spelling..."
    if ! typos; then
        echo "Typos found (run 'typos -w' to fix)"
        FAILED=1
    else
        echo "No typos"
    fi
else
    echo "Warning: typos not found, skipping spellcheck (install: brew install typos-cli)"
fi

# =============================================================================
# Exit
# =============================================================================
echo ""
if [ $FAILED -ne 0 ]; then
    echo "Quality checks failed. Fix errors and try again."
    exit 1
fi

echo "All quality checks passed"
