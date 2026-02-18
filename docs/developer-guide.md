---
layout: default
title: Developer Guide
---

# Developer Guide

Day-to-day workflow for using producer-side composite validation.

## Quick Start

After modifying `low-level-1`, run this one command to validate against the Gradle consumer:

```bash
bazel test //dep-consumer:all --test_output=all
```

If it passes, your changes are safe for the downstream consumer.

## Common Workflows

### Modifying low-level-1's public API

1. Make your changes in `low-level-1/src/main/java/`
2. Run the consumer validation:
   ```bash
   bazel test //dep-consumer:all --test_output=all
   ```
3. If tests fail, you have a breaking change. Either:
   - Adjust your API change to maintain backward compatibility
   - Update the consumer tests in `dep-consumer/src/test/java/` to match the new API
   - Coordinate with the consumer team to update their Gradle repo simultaneously

### Adding a new consumer test

1. Add the test file to `dep-consumer/src/test/java/com/example/consumer/`
2. Add the source file to the `srcs` list in `dep-consumer/BUILD`:
   ```python
   java_test_suite(
       name = "dep-consumer-tests",
       srcs = [
           "src/test/java/com/example/consumer/ApiContractTest.java",
           "src/test/java/com/example/consumer/LowOneMainIntegrationTest.java",
           "src/test/java/com/example/consumer/YourNewTest.java",  # add here
       ],
       ...
   )
   ```
3. Verify Gazelle compatibility:
   ```bash
   bazel run //:gazelle
   git diff dep-consumer/BUILD  # Should be no changes
   ```

### Syncing consumer sources from the Gradle repo

When the `dep-consumer` Gradle repo updates its tests or application code:

1. Copy the updated files:
   ```bash
   cp ../dep-consumer/src/main/java/com/example/consumer/*.java \
      dep-consumer/src/main/java/com/example/consumer/
   cp ../dep-consumer/src/test/java/com/example/consumer/*.java \
      dep-consumer/src/test/java/com/example/consumer/
   ```
2. Update `dep-consumer/BUILD` if new source files were added
3. Verify the build:
   ```bash
   bazel test //dep-consumer:all --test_output=all
   ```

### Querying the dependency graph

See which consumer targets depend on `low-level-1`:

```bash
bazel query 'rdeps(//dep-consumer/..., //low-level-1)'
```

See all targets impacted by a `low-level-1` change:

```bash
bazel query 'rdeps(//..., //low-level-1)'
```

## Troubleshooting

### "Unsupported class file major version 69" warning

This is a benign warning from byte-buddy (AssertJ's transitive dependency) when running on Java 25+. Tests still pass correctly. No action needed.

### Gazelle removes my deps

Ensure cross-package dependencies have the `# keep` comment:

```python
deps = [
    "//low-level-1",  # keep
]
```

Without `# keep`, Gazelle may remove deps it can't resolve through import analysis.

### New maven dependency needed

1. Add the artifact to `MODULE.bazel`'s `maven.install` block
2. Re-pin dependencies:
   ```bash
   bazel run @maven//:pin
   ```
3. Add a Gazelle resolve directive to the root `BUILD` if needed:
   ```python
   # gazelle:resolve java <package> @maven//<target>
   ```

## How It Works

The composite validation works by bringing the consumer's Java sources into the Bazel monorepo as a native Bazel package. Instead of:

```
Traditional: Change producer → publish JAR → switch to consumer repo → run Gradle tests
```

We have:

```
Composite:  Change producer → bazel test //dep-consumer:all
```

The consumer's `dep-consumer/BUILD` declares a dependency on `//low-level-1`, which means Bazel compiles the consumer code directly against the library's compiled classes. Any API incompatibility surfaces as a compile error immediately.

[Back to Home](./)
