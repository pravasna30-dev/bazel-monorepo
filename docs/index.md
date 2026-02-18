---
layout: default
title: Home
---

# Producer-Side Composite Build Validation with Bazel

Validate that changes to a Bazel-built library won't break downstream Gradle consumers — all within a single `bazel test` command.

## The Problem

When a developer modifies `low-level-1` (a Bazel library), they need confidence that downstream consumers won't break. The traditional approach requires publishing the JAR, switching to the Gradle consumer repo, and running its tests. This is slow, error-prone, and easy to skip.

## The Solution

Bring the consumer's Java sources into the Bazel monorepo as a native Bazel package. The consumer's tests compile and run against the Bazel-built library directly — no Gradle, no Maven Local, no multi-step workflow.

```
bazel-monorepo/
├── low-level-1/          # Producer library (Bazel)
├── top-level-1/          # Existing Bazel consumer
├── dep-consumer/         # Gradle consumer sources, built natively in Bazel
│   ├── BUILD
│   ├── src/main/java/    # Application.java
│   └── src/test/java/    # Integration + API contract tests
└── ...
```

### One command catches breaks

```bash
bazel test //dep-consumer:all --test_output=all
```

If a developer renames `say()` to `speak()` in `low-level-1`, the dep-consumer tests fail at **compile time** — before any code is merged.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  bazel-monorepo                  │
│                                                  │
│  ┌──────────────┐     ┌──────────────────────┐  │
│  │  low-level-1 │◄────│    dep-consumer       │  │
│  │  (producer)  │     │  (consumer sources)   │  │
│  │              │     │                       │  │
│  │  LowOneMain  │     │  Application.java     │  │
│  │    .say()    │     │  *IntegrationTest.java│  │
│  │              │     │  *ContractTest.java   │  │
│  └──────────────┘     └──────────────────────┘  │
│         ▲                                        │
│         │                                        │
│  ┌──────────────┐                                │
│  │  top-level-1 │                                │
│  │  (existing)  │                                │
│  └──────────────┘                                │
└─────────────────────────────────────────────────┘
```

### Dependency Graph

`bazel query` confirms the reverse dependency chain:

```bash
$ bazel query 'rdeps(//dep-consumer/..., //low-level-1)'
//dep-consumer:app
//dep-consumer:dep-consumer
//dep-consumer:dep-consumer-tests
//dep-consumer:src/test/java/com/example/consumer/ApiContractTest
//dep-consumer:src/test/java/com/example/consumer/LowOneMainIntegrationTest
//low-level-1:low-level-1
```

---

## Pages

- [Build Targets](./targets.html) — BUILD file structure and Gazelle compatibility
- [Test Strategy](./tests.html) — Integration and API contract tests
- [CI Pipeline](./ci.html) — GitHub Actions workflow for automated validation
- [Developer Guide](./developer-guide.html) — Day-to-day workflow for using composite validation
