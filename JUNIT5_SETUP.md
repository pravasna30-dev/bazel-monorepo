# JUnit 5 Setup Guide

This document explains how to configure and use JUnit 5 tests in this Bazel monorepo.

## Current Setup

The tests have been migrated to JUnit 5 (Jupiter). The configuration supports two approaches:

### Approach 1: Using rules_jvm_external (Recommended when online)

When you have internet access, the WORKSPACE file can use `rules_jvm_external` to automatically fetch JUnit 5 dependencies from Maven Central.

**WORKSPACE configuration**:
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_JVM_EXTERNAL_TAG = "6.0"
RULES_JVM_EXTERNAL_SHA = "4d62589dc6a55e74bbe33930b826d593367fc777449a410604b2ad7c6c625a3f"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazel-contrib/rules_jvm_external/archive/refs/tags/%s.tar.gz" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")
rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")
rules_jvm_external_setup()

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "org.junit.jupiter:junit-jupiter-api:5.10.1",
        "org.junit.jupiter:junit-jupiter-engine:5.10.1",
        "org.junit.platform:junit-platform-launcher:1.10.1",
        "org.junit.platform:junit-platform-console:1.10.1",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
```

Then in BUILD files:
```python
java_test(
    name = "MyTest",
    srcs = glob(["src/test/**/*.java"]),
    test_class = "com.example.MyTest",
    deps = [
        "@maven//:org_junit_jupiter_junit_jupiter_api",
        "@maven//:org_junit_jupiter_junit_jupiter_engine",
        "@maven//:org_junit_platform_junit_platform_launcher",
    ],
)
```

### Approach 2: Using http_jar with direct downloads

Alternatively, you can download JARs directly without rules_jvm_external:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_jar")

JUNIT_JUPITER_VERSION = "5.10.1"
JUNIT_PLATFORM_VERSION = "1.10.1"

http_jar(
    name = "junit_jupiter_api",
    url = "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/%s/junit-jupiter-api-%s.jar" % (JUNIT_JUPITER_VERSION, JUNIT_JUPITER_VERSION),
)

http_jar(
    name = "junit_jupiter_engine",
    url = "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/%s/junit-jupiter-engine-%s.jar" % (JUNIT_JUPITER_VERSION, JUNIT_JUPITER_VERSION),
)

http_jar(
    name = "junit_platform_commons",
    url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-commons/%s/junit-platform-commons-%s.jar" % (JUNIT_PLATFORM_VERSION, JUNIT_PLATFORM_VERSION),
)

http_jar(
    name = "junit_platform_engine",
    url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-engine/%s/junit-platform-engine-%s.jar" % (JUNIT_PLATFORM_VERSION, JUNIT_PLATFORM_VERSION),
)

http_jar(
    name = "junit_platform_launcher",
    url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-launcher/%s/junit-platform-launcher-%s.jar" % (JUNIT_PLATFORM_VERSION, JUNIT_PLATFORM_VERSION),
)

http_jar(
    name = "opentest4j",
    url = "https://repo1.maven.org/maven2/org/opentest4j/opentest4j/1.3.0/opentest4j-1.3.0.jar",
)

http_jar(
    name = "apiguardian",
    url = "https://repo1.maven.org/maven2/org/apiguardian/apiguardian-api/1.1.2/apiguardian-api-1.1.2.jar",
)
```

Then in BUILD files, reference them as:
```python
deps = [
    "@junit_jupiter_api//jar",
    "@junit_jupiter_engine//jar",
    "@junit_platform_commons//jar",
    "@junit_platform_engine//jar",
    "@junit_platform_launcher//jar",
    "@opentest4j//jar",
    "@apiguardian//jar",
]
```

### Approach 3: Local JARs (Offline)

For completely offline environments, download the JARs manually and use `local_repository`:

1. Download JARs to a `third_party/junit5` directory
2. Create a BUILD file in that directory:

```python
java_import(
    name = "junit_jupiter_api",
    jars = ["junit-jupiter-api-5.10.1.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "junit_jupiter_engine",
    jars = ["junit-jupiter-engine-5.10.1.jar"],
    deps = [":junit_jupiter_api"],
    visibility = ["//visibility:public"],
)

# ... more imports
```

3. Reference in tests as `//third_party/junit5:junit_jupiter_api`

## Test Code Structure

Tests use JUnit 5 annotations and the JUnit Platform Console Launcher:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterEach;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class MyTest {
    @BeforeEach
    void setUp() { }

    @AfterEach
    void tearDown() { }

    @Test
    void testSomething() {
        assertEquals(expected, actual);
    }
}
```

## Bazel Test Configuration

The tests use JUnit Platform Console Standalone which includes all necessary JUnit 5 components:

```python
java_test(
    name = "MyTest",
    srcs = glob(["src/test/**/*.java"]),
    test_class = "com.example.MyTest",
    use_testrunner = False,
    main_class = "org.junit.platform.console.ConsoleLauncher",
    args = [
        "--select-class",
        "com.example.MyTest",
    ],
    deps = [
        ":MyLib",
        "@junit_platform_console_standalone//jar",
    ],
)
```

Key configuration elements:
- `use_testrunner = False` - Disables Bazel's default JUnit 4 runner
- `main_class = "org.junit.platform.console.ConsoleLauncher"` - Uses JUnit Platform's console launcher
- `args = ["--select-class", "..."]` - Specifies which test class to run
- `@junit_platform_console_standalone//jar` - All-in-one JAR with JUnit 5 dependencies

## Running Tests

```bash
# Run all tests
bazel test //...

# Run specific test
bazel test //low-level-1:LowLevelOneTest

# Run with verbose output
bazel test //... --test_output=all
```

## Migration from JUnit 4 to JUnit 5

Key changes made:
- `org.junit.Test` → `org.junit.jupiter.api.Test`
- `org.junit.Before` → `org.junit.jupiter.api.BeforeEach`
- `org.junit.After` → `org.junit.jupiter.api.AfterEach`
- `org.junit.Assert.*` → `org.junit.jupiter.api.Assertions.*`
- No more `public` modifier required on test methods

