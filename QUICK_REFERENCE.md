# Bazel Quick Reference

Fast reference for common Bazel commands in this monorepo.

## Essential Commands

### Build

```bash
# Build everything
bazel build //...

# Build specific target
bazel build //low-level-1:LowLevelOne
bazel build //top-level-1:TopLevelOne

# Clean build
bazel clean && bazel build //...

# Full clean (including cache)
bazel clean --expunge
```

### Run

```bash
# Run the application
bazel run //top-level-1:TopLevelOne

# Run with arguments
bazel run //top-level-1:TopLevelOne -- arg1 arg2

# Run from built artifacts
./bazel-bin/top-level-1/TopLevelOne
```

### Test

```bash
# Run all tests (when tests exist)
bazel test //...

# Run specific test
bazel test //module:TestName

# Run with verbose output
bazel test //... --test_output=all
```

### Query

```bash
# List all targets
bazel query //...

# Show dependencies
bazel query 'deps(//top-level-1:TopLevelOne)'

# Show direct dependencies only
bazel query 'deps(//top-level-1:TopLevelOne, 1)'

# Show reverse dependencies
bazel query 'rdeps(//..., //low-level-1:LowLevelOne)'

# Generate dependency graph
bazel query --output=graph 'deps(//...)' > deps.dot
```

### Info

```bash
# Show workspace info
bazel info

# Show output directory
bazel info bazel-bin

# Show Bazel version
bazel version

# Show execution root
bazel info execution_root
```

## Target Patterns

| Pattern | Description |
|---------|-------------|
| `//...` | All targets in workspace |
| `//module:all` | All targets in module |
| `//module:Target` | Specific target |
| `//module/...` | Module and all subdirectories |
| `//...:*` | All targets (all rules) |

## Build Flags

### Common Flags

```bash
# Verbose failures
bazel build //... --verbose_failures

# Show commands being executed
bazel build //... --subcommands

# Build in debug mode
bazel build -c dbg //...

# Build in optimized mode
bazel build -c opt //...
```

### Java-Specific Flags

```bash
# Enable all Java warnings
bazel build //... --javacopt="-Xlint:all"

# Treat warnings as errors
bazel build //... --javacopt="-Werror"

# Set Java version
bazel build //... --java_language_version=21

# Additional compiler options
bazel build //... --javacopt="-g" --javacopt="-parameters"
```

## Project Structure

```
monorepo/
├── MODULE.bazel           # Bzlmod dependency configuration
├── .bazelrc               # Build configuration
├── .bazelversion          # Bazel version (9.0.0)
├── BUILD                  # Root BUILD file
├── low-level-1/           # Library module
│   ├── BUILD
│   └── src/main/java/...
└── top-level-1/           # Binary module
    ├── BUILD
    └── src/main/java/...
```

## Build Artifacts

```
bazel-bin/
├── low-level-1/
│   ├── LowLevelOne.jar          # Library JAR
│   └── libLowLevelOne.jar       # Alternative format
└── top-level-1/
    ├── TopLevelOne              # Executable script
    ├── TopLevelOne.jar          # Runnable JAR
    └── TopLevelOne_deploy.jar   # Fat JAR (all deps)
```

## Dependencies

### Current Architecture

```
TopLevelOne (binary)
    └── LowLevelOne (library)
```

### Dependency Commands

```bash
# Visualize dependencies
bazel query --output=graph 'deps(//...)' | dot -Tpng > deps.png

# Check for circular dependencies
bazel query 'somepath(//module1:A, //module2:B)'

# Find what uses a target
bazel query 'rdeps(//..., //low-level-1:LowLevelOne)'
```

## Troubleshooting

### Cache Issues

```bash
# Clear build cache
bazel clean

# Full clean
bazel clean --expunge

# Restart Bazel server
bazel shutdown
```

### Build Failures

```bash
# Verbose error messages
bazel build //... --verbose_failures

# Show detailed execution
bazel build //... --subcommands --verbose_failures

# Explain what's being rebuilt
bazel build //... --explain=explain.txt
```

### Performance

```bash
# Profile build
bazel build //... --profile=profile.json

# Analyze profile
bazel analyze-profile profile.json

# Parallel builds
bazel build //... --jobs=8
```

## Configuration Files

### .bazelrc

Current configuration:
```
build --java_language_version=21
build --java_runtime_version=local_jdk
build --tool_java_runtime_version=local_jdk
```

### .bazelversion

Locked version:
```
9.0.0
```

### WORKSPACE

```python
workspace(name = "composite_monorepo")
# No external dependencies currently
```

## Quick Tips

### Development Cycle

```bash
# 1. Make changes to code
vim low-level-1/src/main/java/...

# 2. Build and run (only changed parts rebuild)
bazel run //top-level-1:TopLevelOne

# 3. Verify dependencies
bazel query 'deps(//top-level-1:TopLevelOne)'
```

### Adding a New Module

```bash
# 1. Create structure
mkdir -p new-module/src/main/java/com/acme/arc/dep/test

# 2. Create BUILD file
cat > new-module/BUILD << 'EOF'
java_library(
    name = "NewModule",
    srcs = glob(["src/main/java/**/*.java"]),
    visibility = ["//visibility:public"],
)
EOF

# 3. Build it
bazel build //new-module:NewModule
```

### Performance Optimization

```bash
# Use workers for faster incremental builds
bazel build //... --strategy=Javac=worker

# Cache remotely (if configured)
bazel build //... --remote_cache=...

# Parallel execution
bazel build //... --jobs=auto
```

## Environment Variables

```bash
# Set Bazel user root
export BAZEL_USER_ROOT=/tmp/bazel

# Increase heap size
export BAZEL_OPTS="-Xmx4g"

# Use specific Java
export JAVA_HOME=/path/to/jdk21
```

## Version Info

| Component | Version |
|-----------|---------|
| Bazel | 9.0.0 |
| Java | 21 |
| Workspace | composite_monorepo |

## Common Workflows

### Before Committing

```bash
# Full clean build
bazel clean && bazel build //...

# Check for warnings
bazel build //... --javacopt="-Xlint:all" --javacopt="-Werror"

# Run tests (when available)
bazel test //...

# Verify application runs
bazel run //top-level-1:TopLevelOne
```

### Debugging

```bash
# Show what's being built
bazel build //... --subcommands

# Profile build time
bazel build //... --profile=build.json
bazel analyze-profile build.json

# Explain rebuild reasons
bazel build //... --explain=explain.txt
cat explain.txt
```

### Dependency Analysis

```bash
# Full dependency tree
bazel query 'deps(//...)' --output=graph > full_deps.dot

# Path between two targets
bazel query 'somepath(//from:Target, //to:Target)'

# All paths between targets
bazel query 'allpaths(//from:Target, //to:Target)'
```

## Help Commands

```bash
# General help
bazel help

# Command-specific help
bazel help build
bazel help query
bazel help test

# Show all options
bazel help build --long

# Configuration help
bazel help startup_options
```

## Links

- **Full Build Guide:** [BUILD_GUIDE.md](BUILD_GUIDE.md)
- **Architecture:** [CLAUDE.md](CLAUDE.md)
- **Dependencies:** [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Bazel Docs:** https://bazel.build/docs

---

**Quick Reference Version:** 1.0
**Last Updated:** 2026-01-21

