#!/bin/bash

# Generate HTML coverage report for Bazel monorepo
# Usage: ./generate_coverage_report.sh

set -e

echo "================================="
echo "🧪 Bazel Coverage Report Generator"
echo "================================="
echo ""

# Check if lcov is installed
if ! command -v genhtml &> /dev/null; then
    echo "❌ Error: genhtml not found!"
    echo ""
    echo "Please install lcov:"
    echo "  macOS:        brew install lcov"
    echo "  Ubuntu/Debian: sudo apt-get install lcov"
    echo "  RHEL/CentOS:  sudo yum install lcov"
    echo ""
    exit 1
fi

echo "✓ genhtml is installed"
echo ""

# Clean previous coverage data
echo "🧹 Cleaning previous coverage data..."
rm -rf coverage_html
rm -f bazel-out/_coverage/_coverage_report.dat 2>/dev/null || true
echo "✓ Cleaned"
echo ""

# Run tests with coverage
echo "🧪 Running tests with coverage instrumentation..."
echo "   This will download dependencies and run all tests..."
echo ""

if bazel coverage //... --combined_report=lcov; then
    echo ""
    echo "✓ Tests completed successfully"
    echo ""
else
    echo ""
    echo "❌ Tests failed or coverage generation failed"
    echo "   Make sure you have network access to download dependencies"
    exit 1
fi

# Check if coverage data was generated
if [ ! -f "bazel-out/_coverage/_coverage_report.dat" ]; then
    echo "❌ Error: Coverage data file not found!"
    echo "   Expected: bazel-out/_coverage/_coverage_report.dat"
    exit 1
fi

echo "✓ Coverage data generated"
echo ""

# Generate HTML report
echo "📊 Generating HTML coverage report..."
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --title "Bazel Monorepo Coverage Report" \
    --prefix "$(pwd)" \
    --legend \
    --show-details \
    --no-function-coverage \
    --ignore-errors source \
    --quiet

echo "✓ HTML report generated"
echo ""

# Display summary
echo "================================="
echo "✅ Coverage Report Generated!"
echo "================================="
echo ""
echo "📂 Report location: coverage_html/index.html"
echo ""
echo "To view the report:"
echo "  macOS:  open coverage_html/index.html"
echo "  Linux:  xdg-open coverage_html/index.html"
echo "  Manual: file://$(pwd)/coverage_html/index.html"
echo ""

# Optionally auto-open in browser
read -p "Open coverage report in browser now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage_html/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open coverage_html/index.html
    else
        echo "Please open coverage_html/index.html manually"
    fi
fi

echo ""
echo "✨ Done!"
