#!/usr/bin/env bash
set -euo pipefail

# Publish the low-level-1 Bazel-built JAR to Maven Local
# so Gradle consumers can resolve it as com.acme:low-level-1:1.0.0

GROUP_ID="com.acme"
ARTIFACT_ID="low-level-1"
VERSION="${1:-1.0.0}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
M2_DIR="$HOME/.m2/repository/$(echo "$GROUP_ID" | tr '.' '/')/$ARTIFACT_ID/$VERSION"

echo "=== Building //low-level-1 via Bazel ==="
cd "$REPO_ROOT"
bazel build //low-level-1

# Find the output JAR
JAR_PATH="$(bazel cquery --output=files //low-level-1:liblow-level-1.jar 2>/dev/null)" || \
JAR_PATH="$(find bazel-bin/low-level-1 -name 'liblow-level-1.jar' -type f | head -1)"

if [ -z "$JAR_PATH" ] || [ ! -f "$JAR_PATH" ]; then
  echo "ERROR: Could not find liblow-level-1.jar in bazel-bin"
  exit 1
fi

echo "=== Publishing to Maven Local ==="
echo "  JAR: $JAR_PATH"
echo "  GAV: $GROUP_ID:$ARTIFACT_ID:$VERSION"
echo "  Dir: $M2_DIR"

mkdir -p "$M2_DIR"
rm -f "$M2_DIR/$ARTIFACT_ID-$VERSION.jar"
cp "$JAR_PATH" "$M2_DIR/$ARTIFACT_ID-$VERSION.jar"
chmod 644 "$M2_DIR/$ARTIFACT_ID-$VERSION.jar"

# Generate minimal POM
cat > "$M2_DIR/$ARTIFACT_ID-$VERSION.pom" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"
    xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>${GROUP_ID}</groupId>
  <artifactId>${ARTIFACT_ID}</artifactId>
  <version>${VERSION}</version>
  <packaging>jar</packaging>
</project>
EOF

echo "=== Done ==="
echo "Gradle can now resolve: implementation(\"$GROUP_ID:$ARTIFACT_ID:$VERSION\")"
