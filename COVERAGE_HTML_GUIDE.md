# Generating HTML Coverage Reports

This guide explains how to generate HTML coverage reports from Bazel test coverage data.

## Prerequisites

1. **Network access** (to download coverage tools)
2. **genhtml** tool (part of lcov package)

Install genhtml:
```bash
# macOS
brew install lcov

# Ubuntu/Debian
sudo apt-get install lcov

# RHEL/CentOS
sudo yum install lcov
```

## Step 1: Generate Coverage Data

Run Bazel coverage to generate LCOV data:

```bash
# Generate coverage for all tests
bazel coverage //... --combined_report=lcov

# Or for specific module
bazel coverage //low-level-1:LowLevelOneTest --combined_report=lcov
bazel coverage //top-level-1:TopLevelOneTest --combined_report=lcov
```

This creates a coverage report at:
```
bazel-out/_coverage/_coverage_report.dat
```

## Step 2: Convert LCOV to HTML

Use `genhtml` to convert the LCOV data to HTML:

```bash
# Simple command (works without GD module)
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --title "Bazel Monorepo Coverage Report" \
    --legend \
    --show-details \
    --no-function-coverage \
    --ignore-errors source

# Full-featured (requires Perl GD module)
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --title "Test Coverage Report" \
    --prefix $(pwd) \
    --legend \
    --show-details \
    --function-coverage \
    --branch-coverage
```

## Step 3: View HTML Report

Open the report in your browser:

```bash
# macOS
open coverage_html/index.html

# Linux
xdg-open coverage_html/index.html

# Or manually navigate to
# file:///path/to/monorepo/coverage_html/index.html
```

## Complete Workflow Script

Create a script `generate_coverage_report.sh`:

```bash
#!/bin/bash

set -e

echo "🧪 Running tests with coverage..."
bazel coverage //... --combined_report=lcov

echo "📊 Generating HTML coverage report..."
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --title "Bazel Monorepo Coverage Report" \
    --legend \
    --show-details \
    --no-function-coverage \
    --ignore-errors source

echo "✅ Coverage report generated!"
echo "📂 Open: coverage_html/index.html"

# Automatically open in browser (optional)
if [[ "$OSTYPE" == "darwin"* ]]; then
    open coverage_html/index.html
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open coverage_html/index.html
fi
```

Make it executable:
```bash
chmod +x generate_coverage_report.sh
./generate_coverage_report.sh
```

## What the HTML Report Shows

The HTML coverage report includes:

1. **Overall Summary**
   - Total lines, functions, and branches
   - Coverage percentages
   - Color-coded metrics (red/yellow/green)

2. **Directory View**
   - Coverage by package/directory
   - Drill-down navigation

3. **File-Level Details**
   - Line-by-line coverage
   - Executed lines highlighted in green
   - Uncovered lines highlighted in red
   - Execution counts per line

4. **Source Code View**
   - Syntax-highlighted source code
   - Coverage annotations
   - Line numbers
   - Hit counts

## Coverage Report Output Structure

```
coverage_html/
├── index.html              # Main entry point
├── index-sort-f.html       # Sorted by file
├── index-sort-l.html       # Sorted by line coverage
├── low-level-1/
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── acme/
│                       └── arc/
│                           └── dep/
│                               └── test/
│                                   └── LowOneMain.java.gcov.html
├── top-level-1/
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── acme/
│                       └── arc/
│                           └── dep/
│                               └── test/
│                                   └── Main.java.gcov.html
├── gcov.css                # Styling
└── *.png                   # Icons and graphics
```

## Advanced Options

### Filter Coverage by Package

```bash
# Only generate coverage for specific packages
bazel coverage //... \
    --combined_report=lcov \
    --instrumentation_filter="//low-level-1[/:],//top-level-1[/:]"
```

### Set Coverage Thresholds

Add to `.bazelrc`:
```
# Require minimum coverage percentages
coverage --instrumentation_filter="//low-level-1[/:],//top-level-1[/:]"
```

### Generate Coverage in CI/CD

Example GitHub Actions workflow (`.github/workflows/coverage.yml`):

```yaml
name: Coverage

on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install lcov
        run: sudo apt-get install -y lcov

      - name: Generate coverage
        run: |
          bazel coverage //... --combined_report=lcov
          genhtml bazel-out/_coverage/_coverage_report.dat \
            --output-directory coverage_html

      - name: Upload coverage report
        uses: actions/upload-artifact@v3
        with:
          name: coverage-report
          path: coverage_html/

      - name: Comment coverage on PR
        uses: romeovs/lcov-reporter-action@v0.3.1
        with:
          lcov-file: bazel-out/_coverage/_coverage_report.dat
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## Alternative: Coverage.py for HTML Reports

If you prefer Python's coverage.py:

```bash
# Install coverage.py
pip install coverage

# Convert LCOV to coverage.py format (requires lcov_cobertura)
pip install lcov_cobertura
lcov_cobertura bazel-out/_coverage/_coverage_report.dat

# Generate HTML with coverage.py
coverage html
```

## Alternative: SonarQube Integration

For enterprise-grade coverage reporting:

```bash
# Generate LCOV report
bazel coverage //... --combined_report=lcov

# Send to SonarQube
sonar-scanner \
  -Dsonar.projectKey=monorepo \
  -Dsonar.sources=. \
  -Dsonar.java.coveragePlugin=jacoco \
  -Dsonar.coverage.jacoco.xmlReportPaths=bazel-out/_coverage/_coverage_report.dat
```

## Troubleshooting

### Issue: "genhtml: command not found"
**Solution**: Install lcov (see Prerequisites)

### Issue: "Undefined subroutine &main::gen_png called"
**Problem**: genhtml requires Perl GD module to generate PNG graphs

**Solution 1** (Quick Fix - Disable PNGs):
```bash
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --no-function-coverage \
    --ignore-errors source
```

**Solution 2** (Full Fix - Install GD module):
```bash
# macOS
cpan GD::Graph

# Or using system package manager
brew install gd

# Ubuntu/Debian
sudo apt-get install libgd-graph-perl

# RHEL/CentOS
sudo yum install perl-GD-Graph
```

After installing GD, you can use full features:
```bash
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --function-coverage \
    --branch-coverage
```

### Issue: "No coverage data found"
**Solution**: Ensure tests actually ran:
```bash
bazel coverage //... --test_output=all
```

### Issue: Coverage report is empty
**Solution**: Check instrumentation filter:
```bash
bazel coverage //... \
    --instrumentation_filter="^//((?!(third_party):).)*$"
```

### Issue: Permission denied on coverage files
**Solution**: Clean and regenerate:
```bash
bazel clean
bazel coverage //...
```

## Expected Coverage for This Repo

Based on the manual analysis in `TEST_COVERAGE_REPORT.md`, you should see:

- **Overall Coverage**: ~100%
- **low-level-1/LowOneMain.java**: 100% (6/6 lines)
- **top-level-1/Main.java**: 100% (7/7 lines)

## Ignoring Files from Coverage

Create `.lcovrc` to exclude test files:

```
# Exclude test files from coverage
geninfo_exclude = **/test/**
```

Or specify when running genhtml:
```bash
genhtml bazel-out/_coverage/_coverage_report.dat \
    --output-directory coverage_html \
    --ignore-errors source \
    --exclude "*/test/*"
```

## Next Steps

1. Run `./generate_coverage_report.sh` when you have network access
2. Open `coverage_html/index.html` in your browser
3. Explore line-by-line coverage details
4. Add coverage reporting to your CI/CD pipeline
5. Set up coverage badges for your README

## Resources

- [Bazel Coverage Documentation](https://bazel.build/configure/coverage)
- [LCOV Documentation](http://ltp.sourceforge.net/coverage/lcov.php)
- [genhtml Manual](https://linux.die.net/man/1/genhtml)
