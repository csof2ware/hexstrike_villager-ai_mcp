#!/bin/bash

# Test runner script for Villager AI Framework
echo "🧪 Running Villager AI Tests"
echo "============================="

# Resolve project root so script works from root or tests/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ ! -f "${PROJECT_ROOT}/tests/test_villager_ai.py" ]; then
    echo "❌ Error: Could not find project root (tests/test_villager_ai.py not found)"
    exit 1
fi

cd "${PROJECT_ROOT}" || exit 1

# Check if pytest is available
if ! command -v pytest &> /dev/null; then
    echo "❌ Error: pytest is not installed"
    echo "Install it with: pip install pytest pytest-cov"
    exit 1
fi

# Run the tests
echo "Running tests..."
pytest tests/ -v --tb=short

# Check exit code
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed"
    exit 1
fi
