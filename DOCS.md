# Documentation Index

Central index for all documentation in the Bazel monorepo.

## Quick Navigation

### For New Users

1. **[README.md](README.md)** - Start here for project overview
2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Essential commands cheat sheet
3. **[BUILD_GUIDE.md](BUILD_GUIDE.md)** - Comprehensive build instructions

### For Contributors

1. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development workflow and guidelines
2. **[BUILD_GUIDE.md](BUILD_GUIDE.md)** - Advanced build topics
3. **[DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)** - Visualizing dependencies

### For AI Assistants

1. **[CLAUDE.md](CLAUDE.md)** - Architecture and project-specific guidance
2. **[BUILD_GUIDE.md](BUILD_GUIDE.md)** - Build system reference
3. **[DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)** - Dependency structure

---

## Documentation Overview

### Core Documentation

#### README.md
**Purpose:** Project overview and quick start
**Audience:** All users
**Contents:**
- Project description
- Quick start guide
- Basic build commands
- Architecture overview
- Documentation links

**When to read:** First time working with the project

---

#### BUILD_GUIDE.md
**Purpose:** Complete build system documentation
**Audience:** Developers, DevOps, contributors
**Contents:**
- Prerequisites and setup
- Building (all modes and options)
- Running applications
- Testing guidelines
- Dependency management
- Common workflows
- Adding new modules
- Troubleshooting
- CI/CD integration
- Advanced topics

**When to read:**
- Setting up development environment
- Adding new features or modules
- Debugging build issues
- Optimizing build performance
- Setting up CI/CD

**Key sections:**
- [Quick Start](BUILD_GUIDE.md#quick-start)
- [Building](BUILD_GUIDE.md#building)
- [Troubleshooting](BUILD_GUIDE.md#troubleshooting)
- [Adding New Modules](BUILD_GUIDE.md#adding-new-modules)

---

#### QUICK_REFERENCE.md
**Purpose:** Fast command reference
**Audience:** Active developers
**Contents:**
- Essential commands
- Target patterns
- Build flags
- Query examples
- Troubleshooting commands
- Common workflows

**When to read:**
- During daily development
- When you need a quick command reminder
- For copy-paste ready commands

**Use case:** Keep this open while working with Bazel

---

#### CONTRIBUTING.md
**Purpose:** Contributor guidelines
**Audience:** Contributors, team members
**Contents:**
- Development workflow
- Code style guidelines
- Commit message conventions
- Pull request process
- Testing guidelines
- Documentation standards

**When to read:**
- Before making your first contribution
- When creating a pull request
- When adding new features
- For code review reference

**Key sections:**
- [Development Workflow](CONTRIBUTING.md#development-workflow)
- [Commit Guidelines](CONTRIBUTING.md#commit-guidelines)
- [Pull Request Process](CONTRIBUTING.md#pull-request-process)

---

#### DEPENDENCY_GRAPHS.md
**Purpose:** Dependency visualization guide
**Audience:** Architects, developers, product managers
**Contents:**
- Available graph formats (PNG, SVG, JSON, Mermaid, etc.)
- Import instructions for Miro
- Dependency structure explanation
- Graph regeneration instructions

**When to read:**
- Understanding project architecture
- Presenting to stakeholders
- Planning new features
- Analyzing dependencies

**Available formats:**
- PNG - Quick visualization
- SVG - Scalable for presentations
- JSON - Programmatic access
- Mermaid - Documentation
- CSV - Data analysis
- DOT - Graphviz customization

---

#### CLAUDE.md
**Purpose:** AI assistant guidance
**Audience:** Claude Code, AI tools
**Contents:**
- Build system essentials
- Architecture overview
- Dependency patterns
- Command reference
- Module structure

**When to read:**
- When Claude Code is working on the project
- For understanding AI-friendly documentation
- As a concise architecture reference

---

### Configuration Files

#### WORKSPACE
**Purpose:** Bazel workspace definition
**Location:** Root directory
**Contents:**
```python
workspace(name = "composite_monorepo")
# No external dependencies
```

---

#### .bazelrc
**Purpose:** Bazel build configuration
**Location:** Root directory
**Contents:**
```
build --java_language_version=21
build --java_runtime_version=local_jdk
build --tool_java_runtime_version=local_jdk
```

---

#### .bazelversion
**Purpose:** Lock Bazel version
**Location:** Root directory
**Contents:**
```
9.0.0
```

---

### Build Files

#### BUILD (root)
**Purpose:** Root build definitions
**Location:** `/BUILD`
**Contents:** Workspace-level targets (currently empty template)

---

#### low-level-1/BUILD
**Purpose:** Library build definition
**Target:** `//low-level-1:LowLevelOne`
**Type:** `java_library`
**Contents:**
- Source glob pattern
- Public visibility
- No external dependencies

---

#### top-level-1/BUILD
**Purpose:** Binary build definition
**Target:** `//top-level-1:TopLevelOne`
**Type:** `java_binary`
**Contents:**
- Source glob pattern
- Main class definition
- Dependency on low-level-1

---

## Documentation by Use Case

### Getting Started

1. Read [README.md](README.md)
2. Verify prerequisites
3. Run quick start commands
4. Bookmark [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

### Daily Development

- **Quick commands:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Build issues:** [BUILD_GUIDE.md#troubleshooting](BUILD_GUIDE.md#troubleshooting)
- **Code style:** [CONTRIBUTING.md#code-style](CONTRIBUTING.md#code-style)

### Adding Features

1. Review [CONTRIBUTING.md#development-workflow](CONTRIBUTING.md#development-workflow)
2. Check [BUILD_GUIDE.md#adding-new-modules](BUILD_GUIDE.md#adding-new-modules)
3. Update dependency graphs per [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)
4. Follow [CONTRIBUTING.md#pull-request-process](CONTRIBUTING.md#pull-request-process)

### Troubleshooting

1. Check [BUILD_GUIDE.md#troubleshooting](BUILD_GUIDE.md#troubleshooting)
2. Try [QUICK_REFERENCE.md#troubleshooting](QUICK_REFERENCE.md#troubleshooting)
3. Review build configuration files
4. Consult [Bazel documentation](https://bazel.build/docs)

### Architecture Review

1. View [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md)
2. Read [CLAUDE.md#architecture](CLAUDE.md#architecture)
3. Examine [README.md#architecture](README.md#architecture)
4. Query dependencies: `bazel query 'deps(//...)'`

### CI/CD Setup

1. Review [BUILD_GUIDE.md#cicd-integration](BUILD_GUIDE.md#cicd-integration)
2. Check example workflows
3. Test build commands locally
4. Monitor [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for commands

---

## Documentation Maintenance

### Updating Documentation

When making changes to the codebase, update relevant documentation:

| Change Type | Update These Docs |
|-------------|-------------------|
| New module added | README.md, CLAUDE.md, DEPENDENCY_GRAPHS.md |
| Build process changed | BUILD_GUIDE.md, QUICK_REFERENCE.md |
| New workflow | CONTRIBUTING.md, BUILD_GUIDE.md |
| Dependency changed | DEPENDENCY_GRAPHS.md, regenerate graphs |
| Configuration changed | BUILD_GUIDE.md, CLAUDE.md |

### Regenerating Graphs

```bash
# Update dependency graph
bazel query --output=graph 'deps(//...)' > dependency_graph.dot

# Generate visualizations
dot -Tpng dependency_graph.dot -o dependency_graph.png
dot -Tsvg dependency_graph.dot -o dependency_graph.svg

# Update other formats as needed
```

### Documentation Standards

- Use Markdown for all documentation
- Keep table of contents updated
- Include code examples with expected output
- Link between related documents
- Update version and date stamps

---

## Quick Links

### External Resources

- [Bazel Documentation](https://bazel.build/docs)
- [Bazel Java Rules](https://bazel.build/reference/be/java)
- [Bazel Query Reference](https://bazel.build/query/language)
- [Bazel Best Practices](https://bazel.build/configure/best-practices)

### Repository Files

- [Source Code](low-level-1/src/main/java/com/acme/arc/dep/test/)
- [Build Artifacts](bazel-bin/)
- [Dependency Graphs](.) (PNG, SVG, JSON, etc.)

---

## Document Versions

| Document | Version | Last Updated |
|----------|---------|--------------|
| README.md | 1.1 | 2026-01-21 |
| BUILD_GUIDE.md | 1.0 | 2026-01-21 |
| QUICK_REFERENCE.md | 1.0 | 2026-01-21 |
| CONTRIBUTING.md | 1.0 | 2026-01-21 |
| DEPENDENCY_GRAPHS.md | 1.0 | (original) |
| CLAUDE.md | 1.0 | (original) |
| DOCS.md | 1.0 | 2026-01-21 |

---

## Getting Help

1. **Search documentation:** Use ctrl+F in relevant docs
2. **Check quick reference:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
3. **Review examples:** Code examples throughout docs
4. **Consult Bazel docs:** [bazel.build](https://bazel.build)
5. **Ask for help:** File an issue or ask team members

---

**Documentation Index Version:** 1.0
**Last Updated:** 2026-01-21

