---
layout: default
title: CI Pipeline
---

# CI Pipeline

The `.github/workflows/consumer-integration.yml` workflow runs two jobs to validate producer-consumer compatibility on every push and pull request.

## Workflow Overview

```
┌─────────────────┐     ┌────────────────────┐
│   happy-path    │     │  breaking-change   │
│                 │     │                    │
│ 1. Build //...  │     │ 1. Verify baseline │
│ 2. Test consumer│     │ 2. Apply rename    │
│ 3. Query rdeps  │     │ 3. Expect failure  │
└─────────────────┘     └────────────────────┘
```

## Job 1: happy-path

Validates that the current state of the monorepo builds and all consumer tests pass.

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Setup Java
    uses: actions/setup-java@v4
    with:
      java-version: "21"
      distribution: "temurin"
  - name: Build all targets
    run: bazel build //...
  - name: Test dep-consumer
    run: bazel test //dep-consumer:all --test_output=all
  - name: Query reverse dependencies
    run: bazel query 'rdeps(//dep-consumer/..., //low-level-1)'
```

The `rdeps` query is informational — it documents which consumer targets depend on `low-level-1` in the CI log.

## Job 2: breaking-change

Proves that the validation mechanism works by intentionally introducing a breaking change and verifying it's detected.

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Setup Java
    uses: actions/setup-java@v4
    with:
      java-version: "21"
      distribution: "temurin"
  - name: Verify happy path first
    run: bazel test //dep-consumer:all --test_output=errors
  - name: Apply breaking change
    run: |
      sed -i 's/public static void say()/public static void speak()/' \
        low-level-1/src/main/java/com/acme/arc/dep/test/LowOneMain.java
      sed -i 's/say();/speak();/' \
        low-level-1/src/main/java/com/acme/arc/dep/test/LowOneMain.java
  - name: Verify dep-consumer detects breaking change
    run: |
      if bazel test //dep-consumer:all 2>&1; then
        echo "ERROR: Expected compile failure but tests passed!"
        exit 1
      else
        echo "SUCCESS: Breaking change correctly detected."
      fi
```

This job:
1. First confirms the baseline is green
2. Renames `say()` to `speak()` in `LowOneMain.java`
3. Runs consumer tests expecting them to **fail**
4. If the tests unexpectedly pass, the CI job itself fails — alerting that the validation mechanism is broken

## Integration with Existing CI

The monorepo already has a `ci.yml` workflow that runs `bazel test //...`. Since `//dep-consumer:all` is part of `//...`, the consumer tests also run in the main CI pipeline. The `consumer-integration.yml` adds the breaking-change validation as an additional safety net.

## bazel-diff Integration

When using [bazel-diff](https://github.com/Tinder/bazel-diff) for target determination, changes to `low-level-1` will automatically include `//dep-consumer:dep-consumer-tests` as an impacted target due to the transitive dependency chain:

```
//low-level-1:low-level-1
  └── //dep-consumer:dep-consumer
        └── //dep-consumer:dep-consumer-tests
```

This means CI systems using bazel-diff will automatically run consumer tests when the producer changes.

[Back to Home](./)
