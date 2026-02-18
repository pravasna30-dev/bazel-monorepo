---
layout: default
title: Test Strategy
---

# Test Strategy

The dep-consumer package includes two categories of tests that detect breaking changes at different levels.

## Test Types

### 1. Integration Tests (`LowOneMainIntegrationTest`)

Tests that exercise the library's runtime behavior through the consumer's perspective.

**What they catch:**
- Method renames or removals (compile-time failure)
- Output format changes (assertion failure)
- Behavioral regressions (assertion failure)

```java
@Test
void sayShouldPrintExpectedOutput() {
    LowOneMain.say();
    assertThat(outContent.toString().trim()).isEqualTo("Low-level-1");
}
```

These tests capture stdout and verify the library produces the expected output. If `say()` is renamed to `speak()`, the test fails at **compile time** — the strongest possible signal.

### 2. API Contract Tests (`ApiContractTest`)

Reflection-based tests that verify the exact method signatures of the public API.

**What they catch:**
- Method signature changes (visibility, return type, parameters)
- Package relocations
- Access modifier changes

```java
@Test
void verifySayMethodSignature() throws NoSuchMethodException {
    Method method = LowOneMain.class.getMethod("say");

    assertThat(method.getReturnType()).isEqualTo(void.class);
    assertThat(Modifier.isStatic(method.getModifiers())).isTrue();
    assertThat(Modifier.isPublic(method.getModifiers())).isTrue();
    assertThat(method.getParameterCount()).isZero();
}
```

These tests use Java reflection to verify that:
- `LowOneMain.say()` exists as `public static void say()`
- `LowOneMain.main(String[])` exists as `public static void main(String[])`
- The class is in the expected package `com.acme.arc.dep.test`
- The class is public

## Breaking Change Detection Matrix

| Change Type | Integration Tests | Contract Tests | Detection Phase |
|-------------|:-:|:-:|---|
| Method renamed | Compile error | `NoSuchMethodException` | Compile time |
| Method removed | Compile error | `NoSuchMethodException` | Compile time |
| Output changed | Assertion failure | Pass | Runtime |
| Visibility reduced | Compile error | Assertion failure | Compile time |
| Return type changed | Compile error | Assertion failure | Compile time |
| Parameter added | Compile error | Assertion failure | Compile time |
| Package moved | Compile error | Assertion failure | Compile time |

## Running Tests

```bash
# Run all dep-consumer tests
bazel test //dep-consumer:all --test_output=all

# Run specific test
bazel test //dep-consumer:src/test/java/com/example/consumer/ApiContractTest

# Run with verbose output
bazel test //dep-consumer:all --test_output=all --test_verbose_timeout_warnings
```

[Back to Home](./)
