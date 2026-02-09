#!/bin/bash

# Script to fetch SHA256 checksums for JUnit 5 dependencies

JUNIT_JUPITER_VERSION="5.10.1"
JUNIT_PLATFORM_VERSION="1.10.1"

echo "Fetching SHA256 checksums for JUnit 5 dependencies..."
echo ""

echo "junit-jupiter-api:"
curl -sL "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/${JUNIT_JUPITER_VERSION}/junit-jupiter-api-${JUNIT_JUPITER_VERSION}.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"

echo ""
echo "junit-jupiter-engine:"
curl -sL "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/${JUNIT_JUPITER_VERSION}/junit-jupiter-engine-${JUNIT_JUPITER_VERSION}.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"

echo ""
echo "junit-platform-commons:"
curl -sL "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-commons/${JUNIT_PLATFORM_VERSION}/junit-platform-commons-${JUNIT_PLATFORM_VERSION}.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"

echo ""
echo "junit-platform-engine:"
curl -sL "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-engine/${JUNIT_PLATFORM_VERSION}/junit-platform-engine-${JUNIT_PLATFORM_VERSION}.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"

echo ""
echo "junit-platform-launcher:"
curl -sL "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-launcher/${JUNIT_PLATFORM_VERSION}/junit-platform-launcher-${JUNIT_PLATFORM_VERSION}.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"

echo ""
echo "opentest4j:"
curl -sL "https://repo1.maven.org/maven2/org/opentest4j/opentest4j/1.3.0/opentest4j-1.3.0.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"

echo ""
echo "apiguardian-api:"
curl -sL "https://repo1.maven.org/maven2/org/apiguardian/apiguardian-api/1.1.2/apiguardian-api-1.1.2.jar.sha256" || echo "  (fetch from Maven Central or use Bazel error message)"
