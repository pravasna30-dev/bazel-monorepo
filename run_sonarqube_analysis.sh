#!/bin/bash

# Run SonarQube quality analysis on Bazel monorepo
# Usage: ./run_sonarqube_analysis.sh

set -e

echo "======================================="
echo "🔍 SonarQube Quality Analysis"
echo "======================================="
echo ""

# Check if sonar-scanner is installed
if ! command -v sonar-scanner &> /dev/null; then
    echo "❌ Error: sonar-scanner not found!"
    echo ""
    echo "Please install sonar-scanner:"
    echo "  macOS:        brew install sonar-scanner"
    echo "  Ubuntu/Debian: sudo apt-get install sonar-scanner"
    echo "  Manual:       Download from https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/"
    echo ""
    echo "See SONARQUBE_SETUP.md for detailed instructions"
    exit 1
fi

echo "✓ sonar-scanner is installed ($(sonar-scanner --version | head -n1))"
echo ""

# Check if sonar-project.properties exists
if [ ! -f "sonar-project.properties" ]; then
    echo "❌ Error: sonar-project.properties not found!"
    echo "   Please create this file first."
    exit 1
fi

echo "✓ sonar-project.properties found"
echo ""

# Build the project first
echo "🔨 Building project..."
if bazel build //...; then
    echo "✓ Build successful"
    echo ""
else
    echo "❌ Build failed"
    exit 1
fi

# Optional: Generate coverage report first
read -p "Generate coverage report before analysis? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📊 Generating coverage data..."
    echo "   This requires network access to download dependencies..."
    echo ""

    if bazel coverage //... --combined_report=lcov; then
        echo "✓ Coverage data generated"
        echo ""

        # Uncomment coverage settings in sonar-project.properties
        if grep -q "^# sonar.coverage.jacoco.xmlReportPaths" sonar-project.properties; then
            echo "⚠️  Note: Coverage report paths are commented out in sonar-project.properties"
            echo "   You may want to uncomment and configure them for coverage integration"
            echo ""
        fi
    else
        echo "⚠️  Coverage generation failed (network access required)"
        echo "   Continuing with code quality analysis only..."
        echo ""
    fi
fi

# Check for SonarQube server configuration
echo "🔗 Checking SonarQube server configuration..."
echo ""

if [ -z "$SONAR_HOST_URL" ]; then
    echo "⚠️  SONAR_HOST_URL not set"
    echo "   Using default: http://localhost:9000"
    echo ""
    export SONAR_HOST_URL="http://localhost:9000"
fi

if [ -z "$SONAR_TOKEN" ] && [ -z "$SONAR_LOGIN" ]; then
    echo "⚠️  Warning: No authentication token set"
    echo "   Set SONAR_TOKEN environment variable for authentication:"
    echo "   export SONAR_TOKEN=your_token_here"
    echo ""
    echo "   Or use SONAR_LOGIN for older SonarQube versions"
    echo ""
    read -p "Continue without authentication? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Run SonarQube analysis
echo "🔍 Running SonarQube analysis..."
echo "   Server: $SONAR_HOST_URL"
echo ""

# Build the sonar-scanner command
SONAR_CMD="sonar-scanner"

if [ ! -z "$SONAR_TOKEN" ]; then
    SONAR_CMD="$SONAR_CMD -Dsonar.token=$SONAR_TOKEN"
elif [ ! -z "$SONAR_LOGIN" ]; then
    SONAR_CMD="$SONAR_CMD -Dsonar.login=$SONAR_LOGIN"
fi

if [ ! -z "$SONAR_HOST_URL" ]; then
    SONAR_CMD="$SONAR_CMD -Dsonar.host.url=$SONAR_HOST_URL"
fi

# Run the scanner
if eval $SONAR_CMD; then
    echo ""
    echo "======================================="
    echo "✅ SonarQube Analysis Complete!"
    echo "======================================="
    echo ""
    echo "📊 View results at:"
    echo "   $SONAR_HOST_URL/dashboard?id=composite_monorepo"
    echo ""
    echo "Quality metrics analyzed:"
    echo "  • Code smells"
    echo "  • Bugs"
    echo "  • Vulnerabilities"
    echo "  • Security hotspots"
    echo "  • Code coverage (if generated)"
    echo "  • Code duplications"
    echo "  • Maintainability rating"
    echo "  • Reliability rating"
    echo "  • Security rating"
    echo ""
else
    echo ""
    echo "======================================="
    echo "❌ SonarQube Analysis Failed"
    echo "======================================="
    echo ""
    echo "Common issues:"
    echo "  1. SonarQube server not running"
    echo "     → Start server: docker run -d -p 9000:9000 sonarqube:lts-community"
    echo ""
    echo "  2. Invalid authentication token"
    echo "     → Generate token in SonarQube UI: User → My Account → Security"
    echo ""
    echo "  3. Network connectivity issues"
    echo "     → Check server URL and network connection"
    echo ""
    echo "See SONARQUBE_SETUP.md for troubleshooting"
    exit 1
fi

echo "✨ Done!"
