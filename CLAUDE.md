# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build System

This is a Bazel monorepo using Bzlmod-based configuration (`MODULE.bazel`). Bazel version is locked to 9.0.0 via `.bazelversion`.

### Essential Commands

```bash
# Build everything
bazel build //...

# Build specific targets
bazel build //low-level-1:LowLevelOne    # Library
bazel build //top-level-1:TopLevelOne    # Binary

# Run the application
bazel run //top-level-1:TopLevelOne

# Query dependencies
bazel query 'deps(//...)'                # All dependencies
bazel query 'deps(//top-level-1:TopLevelOne)'  # Specific target
```

### Configuration

- **Java Language Version**: 21 (configured in `.bazelrc`)
- **MODULE.bazel**: Bzlmod configuration with `rules_java` and JUnit 5 dependencies
- **External Dependencies**: JUnit 5 JARs via `http_jar` in MODULE.bazel

## Architecture

This monorepo contains two Java modules with a simple dependency relationship:

```
top-level-1 (java_binary) → low-level-1 (java_library)
```

### Module: low-level-1

- **Type**: `java_library`
- **Target**: `//low-level-1:LowLevelOne`
- **Visibility**: Public (can be used by any target in the workspace)
- **Package**: `com.acme.arc.dep.test`
- **Source**: `low-level-1/src/main/java/com/acme/arc/dep/test/LowOneMain.java`
- **Purpose**: Provides low-level functionality via `LowOneMain.say()` method

### Module: top-level-1

- **Type**: `java_binary`
- **Target**: `//top-level-1:TopLevelOne`
- **Main Class**: `com.acme.arc.dep.test.Main`
- **Package**: `com.acme.arc.dep.test`
- **Source**: `top-level-1/src/main/java/com/acme/arc/dep/test/Main.java`
- **Dependencies**: `//low-level-1:LowLevelOne`
- **Purpose**: Executable application that depends on and calls low-level-1

### Dependency Declaration Pattern

When adding dependencies between modules in this monorepo:

1. In the consuming module's BUILD file, add to `deps`:
   ```python
   deps = [
       "//module-name:TargetName",
   ]
   ```

2. Ensure the providing module's target has `visibility = ["//visibility:public"]`

### Source Organization

All Java sources follow the standard Maven/Gradle layout:
```
module-name/
  src/
    main/
      java/
        com/acme/arc/dep/test/
          *.java
```

BUILD files use `glob(["src/main/java/com/acme/arc/dep/test/*.java"])` to collect sources.

## Testing

Tests use JUnit 5 (Jupiter) with the JUnit Platform Console Launcher.

### Running Tests

```bash
# Run all tests
bazel test //...

# Run specific module tests
bazel test //low-level-1:LowLevelOneTest
bazel test //top-level-1:TopLevelOneTest

# Run with verbose output
bazel test //... --test_output=all
```

### Test Configuration

Tests are configured to use JUnit Platform Console Standalone:

```python
java_test(
    name = "MyTest",
    srcs = glob(["src/test/**/*.java"]),
    use_testrunner = False,  # Disable default JUnit 4 runner
    main_class = "org.junit.platform.console.ConsoleLauncher",
    args = ["--select-class", "com.example.MyTest"],
    deps = [
        ":MyLib",
        "@junit_platform_console_standalone//jar",
    ],
)
```

See `JUNIT5_SETUP.md` for detailed JUnit 5 configuration and migration guide.

The repository includes pre-generated dependency graphs in multiple formats (DOT, SVG, PNG, CSV, JSON, Mermaid) for visualization in tools like Miro. See `DEPENDENCY_GRAPHS.md` for details on importing these diagrams.

To regenerate the full Bazel dependency graph:
```bash
bazel query --output=graph 'deps(//...)' > dependency_graph.dot
```

## Origin

This monorepo was created by merging two separate Bazel projects:
- bazel-low-level-1 (library)
- bazel-top-level-1 (binary)

The original top-level-1 dependency on mid-level-1 was replaced with low-level-1.

