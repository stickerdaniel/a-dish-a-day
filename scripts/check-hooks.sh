#!/bin/bash

# Skip in CI environments
if [ -n "$CI" ]; then
    echo "⏭️  Skipping hook check in CI environment."
    exit 0
fi

# Check if hooks are configured
HOOKS_PATH=$(git config core.hooksPath)

if [ "$HOOKS_PATH" != "scripts/hooks" ]; then
    echo "❌ Git hooks not configured!"
    echo ""
    echo "   Run this command to enable pre-commit formatting:"
    echo ""
    echo "   git config core.hooksPath scripts/hooks"
    echo ""
    exit 1
fi

echo "✅ Git hooks configured."
