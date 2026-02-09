# Build Guide

Complete guide for building, testing, and working with this Bazel monorepo.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Building](#building)
- [Running](#running)
- [Testing](#testing)
- [Dependency Management](#dependency-management)
- [Common Workflows](#common-workflows)
- [Adding New Modules](#adding-new-modules)
- [Troubleshooting](#troubleshooting)
- [CI/CD Integration](#cicd-integration)
- [Advanced Topics](#advanced-topics)

---

## Prerequisites

### Required Software

| Tool | Version | Installation |
|------|---------|--------------|
| **Bazel** | 9.0.0 (locked) | [bazel.build](https://bazel.build/install) |
| **Java JDK** | 21+ | [OpenJDK](https://openjdk.org/) or `brew install openjdk@21` |

### Verification

```bash
# Check Bazel version
bazel version

# Check Java version
java -version

# Verify workspace setup
bazel info workspace
```

---

## Quick Start

```bash
# Clone the repository (if not already cloned)
cd /path/to/monorepo

# Build everything
bazel build //...

# Run the application
bazel run //top-level-1:TopLevelOne
```

**Expected output:**
```
Top-level-1
Low-level-1
```

---

## Building

### Build All Targets

```bash
bazel build //...
```

This builds:
- `//low-level-1:LowLevelOne` (library)
- `//top-level-1:TopLevelOne` (binary)

**Output:**
```
INFO: Analyzed 2 targets (0 packages loaded, 0 targets configured).
INFO: Found 2 targets...
INFO: Build completed successfully, 1 total action
```

### Build Specific Targets

```bash
# Build the library only
bazel build //low-level-1:LowLevelOne

# Build the binary only
bazel build //top-level-1:TopLevelOne

# Build with verbose output
bazel build //top-level-1:TopLevelOne --verbose_failures

# Build with compilation warnings
bazel build //... --javacopt="-Xlint:all"
```

### Build Artifacts Location

After building, artifacts are located in:

```
bazel-bin/
├── low-level-1/
│   ├── LowLevelOne.jar
│   └── libLowLevelOne.jar
└── top-level-1/
    ├── TopLevelOne              # Executable wrapper script
    ├── TopLevelOne.jar          # Runnable JAR
    └── TopLevelOne_deploy.jar   # Fat JAR with all dependencies
```

### Build Modes

```bash
# Optimized build (default)
bazel build -c opt //...

# Debug build with assertions
bazel build -c dbg //...

# Fast incremental build
bazel build -c fastbuild //...
```

---

## Running

### Run the Application

```bash
# Standard run
bazel run //top-level-1:TopLevelOne

# Run with arguments
bazel run //top-level-1:TopLevelOne -- arg1 arg2

# Run with Java system properties
bazel run //top-level-1:TopLevelOne -- -Dproperty=value
```

### Run Directly from Built Artifacts

```bash
# After building, run the wrapper script
./bazel-bin/top-level-1/TopLevelOne

# Or use java -jar
java -jar bazel-bin/top-level-1/TopLevelOne_deploy.jar
```

---

## Testing

### Current State

This monorepo currently has no test targets defined.

### Adding Tests

To add tests to a module:

1. **Create test source files:**
   ```
   low-level-1/src/test/java/com/acme/arc/dep/test/LowOneMainTest.java
   ```

2. **Update BUILD file:**
   ```python
   java_test(
       name = "LowOneMainTest",
       srcs = glob(["src/test/java/**/*.java"]),
       test_class = "com.acme.arc.dep.test.LowOneMainTest",
       deps = [
           ":LowLevelOne",
           # Add test dependencies like JUnit
       ],
   )
   ```

3. **Run tests:**
   ```bash
   bazel test //low-level-1:LowOneMainTest
   bazel test //...  # Run all tests
   ```

---

## Dependency Management

### Query Dependencies

```bash
# Show all dependencies for a target
bazel query 'deps(//top-level-1:TopLevelOne)'

# Show only direct dependencies
bazel query 'deps(//top-level-1:TopLevelOne, 1)'

# Show all dependencies in the workspace
bazel query 'deps(//...)'

# Output as graph (DOT format)
bazel query --output=graph 'deps(//...)' > dependencies.dot

# Visualize with Graphviz
dot -Tpng dependencies.dot -o dependencies.png
```

### Reverse Dependencies

```bash
# Find what depends on low-level-1
bazel query 'rdeps(//..., //low-level-1:LowLevelOne)'

# Find all targets that depend on a specific target
bazel query 'allrdeps(//low-level-1:LowLevelOne)'
```

### Dependency Graph Files

Pre-generated dependency graphs are available in multiple formats:

| File | Format | Use Case |
|------|--------|----------|
| `dependency_graph.png` | PNG | Quick reference |
| `dependency_graph.svg` | SVG | Miro/presentations |
| `dependency_graph.csv` | CSV | Data analysis |
| `dependency_graph.json` | JSON | Programmatic access |
| `dependency_graph.mmd` | Mermaid | Documentation |

See [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md) for import instructions.

---

## Common Workflows

### Clean Build

```bash
# Clean all build artifacts
bazel clean

# Deep clean including external repositories
bazel clean --expunge

# Rebuild from scratch
bazel clean && bazel build //...
```

### Incremental Development

```bash
# 1. Make code changes
vim low-level-1/src/main/java/com/acme/arc/dep/test/LowOneMain.java

# 2. Build and run (only changed parts rebuild)
bazel run //top-level-1:TopLevelOne

# 3. Verify with query
bazel query 'deps(//top-level-1:TopLevelOne)'
```

### Code Formatting and Linting

```bash
# Build with all Java warnings enabled
bazel build //... --javacopt="-Xlint:all"

# Build with deprecation warnings
bazel build //... --javacopt="-Xlint:deprecation"

# Treat warnings as errors
bazel build //... --javacopt="-Werror"
```

### Performance Analysis

```bash
# Profile build performance
bazel build //... --profile=build_profile.json

# Analyze profile
bazel analyze-profile build_profile.json

# Show execution graph
bazel build //... --explain=explain.log
```

---

## Adding New Modules

### Create a New Library

1. **Create directory structure:**
   ```bash
   mkdir -p new-module/src/main/java/com/acme/arc/dep/test
   ```

2. **Create BUILD file:**
   ```python
   # new-module/BUILD
   java_library(
       name = "NewModule",
       srcs = glob(["src/main/java/com/acme/arc/dep/test/*.java"]),
       visibility = ["//visibility:public"],
       deps = [
           # Add dependencies here
       ],
   )
   ```

3. **Create Java source:**
   ```java
   // new-module/src/main/java/com/acme/arc/dep/test/NewModuleMain.java
   package com.acme.arc.dep.test;

   public class NewModuleMain {
       public static void doSomething() {
           System.out.println("New module");
       }
   }
   ```

4. **Build and verify:**
   ```bash
   bazel build //new-module:NewModule
   ```

### Create a New Binary

1. **Follow library steps above, then change rule to:**
   ```python
   java_binary(
       name = "NewBinary",
       srcs = glob(["src/main/java/com/acme/arc/dep/test/*.java"]),
       main_class = "com.acme.arc.dep.test.MainClass",
       deps = [
           "//low-level-1:LowLevelOne",
       ],
   )
   ```

2. **Run it:**
   ```bash
   bazel run //new-module:NewBinary
   ```

### Add Dependency Between Modules

1. **In consuming module's BUILD file:**
   ```python
   deps = [
       "//new-module:NewModule",
   ]
   ```

2. **In Java code:**
   ```java
   import com.acme.arc.dep.test.NewModuleMain;

   NewModuleMain.doSomething();
   ```

3. **Verify dependency:**
   ```bash
   bazel query 'deps(//your-module:YourTarget)'
   ```

---

## Troubleshooting

### Build Failures

#### Java Version Mismatch

**Error:**
```
ERROR: Java version mismatch
```

**Solution:**
```bash
# Check configured version
grep java_language_version .bazelrc

# Verify Java installation
java -version

# Update .bazelrc if needed
build --java_language_version=21
```

#### Cache Issues

**Symptom:** Stale build artifacts or unexpected behavior

**Solution:**
```bash
# Clear Bazel cache
bazel clean

# Full clean including external deps
bazel clean --expunge

# Shutdown Bazel server
bazel shutdown
```

#### Dependency Resolution

**Error:**
```
ERROR: Target '//module:Target' not found
```

**Solution:**
```bash
# List all available targets
bazel query //...

# Check if target exists
bazel query //module:Target

# Verify BUILD file syntax
cat module/BUILD
```

### Performance Issues

#### Slow Builds

```bash
# Check what's being rebuilt
bazel build //... --explain=explain.log
cat explain.log

# Use build profile
bazel build //... --profile=profile.json
bazel analyze-profile profile.json

# Enable worker strategy
bazel build //... --strategy=Javac=worker
```

#### Disk Space

```bash
# Check Bazel disk usage
bazel info output_base
du -sh $(bazel info output_base)

# Clean old artifacts
bazel clean
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `No such package` | BUILD file missing | Create BUILD file in directory |
| `Target not declared` | Rule name mismatch | Check BUILD file rule names |
| `Circular dependency` | Module depends on itself | Restructure dependencies |
| `Java compilation failed` | Syntax error | Check Java source files |
| `Permission denied` | File permissions | `chmod +x` or check ownership |

---

## CI/CD Integration

### Continuous Integration

**Example GitHub Actions workflow:**

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          java-version: '21'
          distribution: 'temurin'

      - name: Setup Bazel
        run: |
          wget https://github.com/bazelbuild/bazel/releases/download/9.0.0/bazel-9.0.0-installer-linux-x86_64.sh
          chmod +x bazel-9.0.0-installer-linux-x86_64.sh
          ./bazel-9.0.0-installer-linux-x86_64.sh --user
          export PATH="$PATH:$HOME/bin"

      - name: Build
        run: bazel build //...

      - name: Test
        run: bazel test //...

      - name: Run Application
        run: bazel run //top-level-1:TopLevelOne
```

### Build Scripts

**build.sh:**
```bash
#!/bin/bash
set -e

echo "Building monorepo..."
bazel build //...

echo "Running tests..."
bazel test //... || true  # Continue even if no tests

echo "Build complete!"
```

### Docker Build

**Dockerfile:**
```dockerfile
FROM eclipse-temurin:21-jdk

# Install Bazel
RUN apt-get update && apt-get install -y wget
RUN wget https://github.com/bazelbuild/bazel/releases/download/9.0.0/bazel-9.0.0-installer-linux-x86_64.sh
RUN chmod +x bazel-9.0.0-installer-linux-x86_64.sh
RUN ./bazel-9.0.0-installer-linux-x86_64.sh

# Copy workspace
WORKDIR /workspace
COPY . .

# Build
RUN bazel build //...

# Run application
CMD ["bazel", "run", "//top-level-1:TopLevelOne"]
```

---

## Advanced Topics

### Bazel Configuration

#### Custom .bazelrc Options

```bash
# Add to .bazelrc for team-wide settings

# Enable persistent workers for faster builds
build --worker_sandboxing

# Set default build mode
build --compilation_mode=opt

# Increase parallel jobs
build --jobs=8

# Custom Java options
build --javacopt="-Xlint:all"
build --javacopt="-Werror"
```

#### Build Flags

```bash
# Verbose build
bazel build //... --verbose_failures --subcommands

# Show command lines
bazel build //... --subcommands=pretty_print

# Analyze dependencies
bazel build //... --experimental_show_artifacts

# Remote caching (if configured)
bazel build //... --remote_cache=https://cache.example.com
```

### Workspace Optimization

#### Selective Builds

```bash
# Build only changed targets
bazel build $(bazel query 'kind(java_.*, changed(//...))')

# Build targets matching pattern
bazel build $(bazel query 'filter(".*Test", //...)')
```

#### Build Event Protocol

```bash
# Export build events
bazel build //... --build_event_json_file=events.json

# Analyze events
cat events.json | jq '.targetCompleted'
```

### Debugging Builds

```bash
# Show all actions
bazel build //... --subcommands

# Debug target resolution
bazel query //... --output=build

# Show toolchain info
bazel build //... --toolchain_resolution_debug

# Verbose output
bazel build //... -s
```

### Migration from Maven/Gradle

If migrating from Maven or Gradle:

1. **Dependency mapping:**
   - Maven `<dependency>` → Bazel `deps = []`
   - Gradle `implementation` → Bazel `deps = []`

2. **External dependencies:**
   - Use `rules_jvm_external` for Maven artifacts
   - Update WORKSPACE with external repository rules

3. **Build phases:**
   - Maven lifecycle → Bazel rules
   - `mvn compile` → `bazel build`
   - `mvn test` → `bazel test`
   - `mvn package` → `bazel build` (creates JARs automatically)

---

## Reference

### Bazel Commands Cheat Sheet

| Command | Purpose |
|---------|---------|
| `bazel build //...` | Build all targets |
| `bazel run //module:Target` | Run a binary target |
| `bazel test //...` | Run all tests |
| `bazel query 'deps(//...)'` | Query dependencies |
| `bazel clean` | Clean build artifacts |
| `bazel info` | Show workspace info |
| `bazel version` | Show Bazel version |
| `bazel shutdown` | Stop Bazel server |

### Target Patterns

| Pattern | Matches |
|---------|---------|
| `//...` | All targets in workspace |
| `//module:all` | All targets in module |
| `//module:Target` | Specific target |
| `//module/...` | All targets in module and subdirs |
| `//...:java_*` | All Java targets |

### Configuration Files

| File | Purpose |
|------|---------|
| `MODULE.bazel` | Bzlmod configuration and external deps |
| `BUILD` | Build rules and target definitions |
| `.bazelrc` | Bazel configuration options |
| `.bazelversion` | Bazel version lock |
| `.bazelignore` | Directories to ignore |

---

## Additional Resources

- **Bazel Documentation:** https://bazel.build/docs
- **Java Rules:** https://bazel.build/reference/be/java
- **Query Language:** https://bazel.build/query/language
- **Best Practices:** https://bazel.build/configure/best-practices
- **Dependency Graphs:** See [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)
- **Project Guide:** See [CLAUDE.md](CLAUDE.md)

---

## Getting Help

1. **Check build output:** Bazel provides detailed error messages
2. **Query the workspace:** Use `bazel query` to inspect targets
3. **Review configuration:** Check `.bazelrc`, `WORKSPACE`, and `BUILD` files
4. **Clean and rebuild:** `bazel clean && bazel build //...`
5. **Consult documentation:** Official Bazel docs and this guide

---

**Document Version:** 1.0
**Last Updated:** 2026-01-21
**Bazel Version:** 9.0.0
**Java Version:** 21

