---
layout: default
title: Build Targets
---

# Build Targets

The `dep-consumer/BUILD` file defines four targets that mirror the Gradle consumer's structure using native Bazel rules.

## BUILD File

```python
load("@contrib_rules_jvm//java:defs.bzl", "java_test_suite")
load("@rules_java//java:defs.bzl", "java_binary", "java_library")

# gazelle:java_module_granularity module

java_library(
    name = "dep-consumer",
    srcs = ["src/main/java/com/example/consumer/Application.java"],
    visibility = ["//visibility:public"],
    deps = ["//low-level-1"],  # keep
)

java_binary(
    name = "app",
    main_class = "com.example.consumer.Application",
    runtime_deps = [":dep-consumer"],
)

java_test_suite(
    name = "dep-consumer-tests",
    size = "small",
    srcs = [
        "src/test/java/com/example/consumer/ApiContractTest.java",
        "src/test/java/com/example/consumer/LowOneMainIntegrationTest.java",
    ],
    runner = "junit5",
    deps = [
        ":dep-consumer",  # keep
        "//low-level-1",  # keep
        "@maven//:org_assertj_assertj_core",
        "@maven//:org_junit_jupiter_junit_jupiter_api",
    ],
    runtime_deps = [
        "@maven//:org_junit_jupiter_junit_jupiter_engine",
        "@maven//:org_junit_platform_junit_platform_launcher",
        "@maven//:org_junit_platform_junit_platform_reporting",
    ],
)
```

## Target Details

| Target | Type | Purpose |
|--------|------|---------|
| `:dep-consumer` | `java_library` | Consumer application code, depends on `//low-level-1` |
| `:app` | `java_binary` | Runnable binary for the consumer application |
| `:dep-consumer-tests` | `java_test_suite` | JUnit 5 integration and contract tests |

## Gazelle Compatibility

The BUILD file is designed to coexist with Gazelle (the automatic BUILD file generator):

### `# gazelle:java_module_granularity module`
Tells Gazelle to treat the entire package as one module rather than creating per-file targets.

### Explicit `srcs` (no `glob()`)
Gazelle cannot merge with `glob()` expressions. By listing source files explicitly, Gazelle can update the BUILD file without conflicts.

### `# keep` comments
The `# keep` comment on deps like `"//low-level-1"` prevents Gazelle from removing cross-package references it doesn't understand.

### Idempotence check
After any change, verify Gazelle produces no diff:

```bash
bazel run //:gazelle
git diff dep-consumer/BUILD  # Should be empty
```

## Maven Dependencies

The consumer tests use AssertJ for fluent assertions. These were added to `MODULE.bazel`:

```python
"org.assertj:assertj-core:3.25.3",
"net.bytebuddy:byte-buddy:1.14.11",  # transitive dep of AssertJ
```

The root BUILD includes a Gazelle resolve directive so it knows how to map the import:

```python
# gazelle:resolve java org.assertj.core.api @maven//:org_assertj_assertj_core
```

[Back to Home](./)
