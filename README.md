# Composite Monorepo

This monorepo contains two Bazel projects merged together:
- `low-level-1`: A Java library providing low-level functionality
- `top-level-1`: A Java binary that depends on `low-level-1`

## Documentation

| Document | Description |
|----------|-------------|
| **[BUILD_GUIDE.md](BUILD_GUIDE.md)** | Complete build guide with troubleshooting and advanced topics |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Fast reference for common Bazel commands |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Guidelines for contributors and developers |
| **[DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)** | Dependency visualization in multiple formats |
| **[CLAUDE.md](CLAUDE.md)** | Architecture and guidance for Claude Code |

## Structure

```
monorepo/
├── WORKSPACE              # Bazel workspace configuration
├── .bazelrc               # Bazel configuration options
├── .bazelversion          # Specifies Bazel version (7.4.1)
├── BUILD                  # Root BUILD file
├── low-level-1/
│   ├── BUILD              # Defines LowLevelOne java_library
│   └── src/
│       └── main/java/com/acme/arc/dep/test/
│           └── LowOneMain.java
└── top-level-1/
    ├── BUILD              # Defines TopLevelOne java_binary
    └── src/
        └── main/java/com/acme/arc/dep/test/
            └── Main.java
```

## Quick Start

### Prerequisites

- **Bazel** 7.4.1 (locked via `.bazelversion`)
- **Java JDK** 21+

### Build and Run

```bash
# Build all targets
bazel build //...

# Run the application
bazel run //top-level-1:TopLevelOne
```

**Expected output:**
```
Top-level-1
Low-level-1
```

### Common Commands

```bash
# Build specific target
bazel build //low-level-1:LowLevelOne

# Query dependencies
bazel query 'deps(//top-level-1:TopLevelOne)'

# Clean build
bazel clean
```

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for more commands or [BUILD_GUIDE.md](BUILD_GUIDE.md) for comprehensive instructions.

## Architecture

```
TopLevelOne (java_binary)
    └── depends on → LowLevelOne (java_library)
```

### Module Details

**low-level-1** (`//low-level-1:LowLevelOne`)
- Type: `java_library`
- Visibility: Public
- Package: `com.acme.arc.dep.test`
- Provides: `LowOneMain.say()` method

**top-level-1** (`//top-level-1:TopLevelOne`)
- Type: `java_binary`
- Main class: `com.acme.arc.dep.test.Main`
- Depends on: `//low-level-1:LowLevelOne`
- Executable: Runs both Main and LowOneMain

See [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md) for visual diagrams in multiple formats (PNG, SVG, JSON, Mermaid, etc.).

## Configuration

| File | Purpose |
|------|---------|
| **WORKSPACE** | Workspace definition (no external dependencies) |
| **.bazelrc** | Java 21, disables Bzlmod |
| **.bazelversion** | Locks Bazel to 7.4.1 |
| **BUILD** | Root build file |

## Adding New Modules

```bash
# 1. Create module structure
mkdir -p new-module/src/main/java/com/acme/arc/dep/test

# 2. Create BUILD file
cat > new-module/BUILD << 'EOF'
java_library(
    name = "NewModule",
    srcs = glob(["src/main/java/**/*.java"]),
    visibility = ["//visibility:public"],
    deps = ["//low-level-1:LowLevelOne"],
)
EOF

# 3. Build it
bazel build //new-module:NewModule
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Development

- **Build Guide:** [BUILD_GUIDE.md](BUILD_GUIDE.md) - Comprehensive build instructions
- **Quick Reference:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command cheat sheet
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) - Development workflow and guidelines

## History

This monorepo was created by merging two separate Bazel projects (`bazel-low-level-1` and `bazel-top-level-1`).

The original `top-level-1` dependency on `mid-level-1` has been replaced with `low-level-1`.

