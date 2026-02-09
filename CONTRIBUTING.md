# Contributing Guide

Guidelines for contributing to this Bazel monorepo.

## Getting Started

1. **Read the documentation:**
   - [BUILD_GUIDE.md](BUILD_GUIDE.md) - Complete build instructions
   - [CLAUDE.md](CLAUDE.md) - Project architecture and guidelines
   - [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md) - Dependency visualization

2. **Set up your environment:**
   ```bash
   # Verify prerequisites
   bazel version  # Should be 9.0.0
   java -version  # Should be 21+

   # Build and test
   bazel build //...
   bazel run //top-level-1:TopLevelOne
   ```

## Development Workflow

### Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Follow existing code structure
   - Maintain package organization: `com.acme.arc.dep.test`
   - Use standard Maven directory layout

3. **Build and verify:**
   ```bash
   # Build everything
   bazel build //...

   # Run the application
   bazel run //top-level-1:TopLevelOne

   # Check dependencies
   bazel query 'deps(//your-module:YourTarget)'
   ```

4. **Test your changes:**
   ```bash
   # Run tests (when available)
   bazel test //...

   # Verify no build errors
   bazel build //... --javacopt="-Xlint:all" --javacopt="-Werror"
   ```

### Adding New Modules

When adding a new module, follow this pattern:

1. **Create directory structure:**
   ```
   new-module/
   ├── BUILD
   └── src/
       └── main/
           └── java/
               └── com/acme/arc/dep/test/
                   └── YourClass.java
   ```

2. **Create BUILD file:**
   ```python
   java_library(
       name = "NewModule",
       srcs = glob(["src/main/java/com/acme/arc/dep/test/*.java"]),
       visibility = ["//visibility:public"],
       deps = [
           # Add dependencies here
       ],
   )
   ```

3. **Update dependency graphs:**
   ```bash
   # Regenerate dependency graph
   bazel query --output=graph 'deps(//...)' > dependency_graph.dot

   # Create visualizations
   dot -Tpng dependency_graph.dot -o dependency_graph.png
   dot -Tsvg dependency_graph.dot -o dependency_graph.svg
   ```

4. **Update documentation:**
   - Update README.md with new module description
   - Update CLAUDE.md architecture section
   - Regenerate dependency graphs if needed

### Code Style

#### Java Code

- **Package structure:** `com.acme.arc.dep.test`
- **Naming conventions:**
  - Classes: PascalCase (e.g., `LowOneMain`)
  - Methods: camelCase (e.g., `doSomething()`)
  - Constants: UPPER_SNAKE_CASE (e.g., `MAX_VALUE`)
- **Formatting:** Follow standard Java conventions
- **Imports:** Organize and remove unused imports

#### BUILD Files

- **Naming:** Use PascalCase for target names matching class/module names
- **Organization:**
  ```python
  # Rule type
  java_library(
      name = "TargetName",        # Target name
      srcs = glob([...]),          # Source files
      visibility = [...],          # Visibility
      deps = [                     # Dependencies (sorted)
          "//module1:Target1",
          "//module2:Target2",
      ],
  )
  ```
- **Comments:** Add comments for non-obvious configurations
- **Sorting:** Keep deps alphabetically sorted

#### Configuration Files

- **.bazelrc:** Add comments explaining each flag
- **WORKSPACE:** Document external dependencies
- **.bazelversion:** Keep locked to tested version

## Commit Guidelines

### Commit Messages

Follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (deps, build config)
- `build`: Build system changes

**Examples:**
```
feat(low-level-1): add logging utility

Added a new logging utility class to provide structured
logging across the low-level library.

feat(top-level-1): integrate with new logging

Updated Main.java to use the new logging utility from
low-level-1 for consistent output formatting.

docs: update build guide with testing section

Added comprehensive testing documentation including
how to add new tests and run them with Bazel.

build: upgrade to Java 21

Updated .bazelrc to use Java 21 and verified all
modules compile successfully with the new version.
```

### Commit Best Practices

- One logical change per commit
- Reference issue numbers when applicable
- Keep commits focused and atomic
- Write clear, descriptive commit messages
- Test before committing

## Pull Request Process

### Before Submitting

1. **Ensure builds succeed:**
   ```bash
   bazel clean
   bazel build //...
   ```

2. **Run all tests:**
   ```bash
   bazel test //...
   ```

3. **Check for warnings:**
   ```bash
   bazel build //... --javacopt="-Xlint:all"
   ```

4. **Update documentation:**
   - Update README.md if adding new modules
   - Update BUILD_GUIDE.md if adding new workflows
   - Update dependency graphs if structure changed

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring
- [ ] Build/configuration change

## Changes Made
- List of specific changes
- Another change
- Etc.

## Testing
Describe testing performed:
- [ ] Builds successfully (`bazel build //...`)
- [ ] Tests pass (`bazel test //...`)
- [ ] Application runs (`bazel run //top-level-1:TopLevelOne`)
- [ ] No new warnings

## Dependencies
List any new dependencies or version changes

## Documentation
- [ ] README.md updated (if needed)
- [ ] BUILD_GUIDE.md updated (if needed)
- [ ] CLAUDE.md updated (if needed)
- [ ] Dependency graphs regenerated (if needed)

## Related Issues
Fixes #issue_number
```

### PR Review Checklist

**For Reviewers:**
- [ ] Code follows project conventions
- [ ] BUILD files properly structured
- [ ] Dependencies correctly declared
- [ ] No circular dependencies introduced
- [ ] Documentation updated
- [ ] Builds successfully
- [ ] Tests pass (when available)
- [ ] Commit messages follow guidelines

## Testing

### Current State

The monorepo currently has no test targets. When adding tests:

### Adding Unit Tests

1. **Create test directory:**
   ```bash
   mkdir -p module/src/test/java/com/acme/arc/dep/test
   ```

2. **Add test class:**
   ```java
   package com.acme.arc.dep.test;

   import org.junit.Test;
   import static org.junit.Assert.*;

   public class YourClassTest {
       @Test
       public void testSomething() {
           // Test implementation
       }
   }
   ```

3. **Update BUILD file:**
   ```python
   java_test(
       name = "YourClassTest",
       srcs = glob(["src/test/java/**/*Test.java"]),
       test_class = "com.acme.arc.dep.test.YourClassTest",
       deps = [
           ":YourModule",
           "@maven//:junit_junit",
       ],
   )
   ```

4. **Run tests:**
   ```bash
   bazel test //module:YourClassTest
   ```

### Integration Tests

For integration tests that span multiple modules:

```python
java_test(
    name = "IntegrationTest",
    srcs = ["IntegrationTest.java"],
    test_class = "com.acme.arc.dep.test.IntegrationTest",
    deps = [
        "//low-level-1:LowLevelOne",
        "//top-level-1:TopLevelOne",
    ],
)
```

## Dependency Management

### Adding Dependencies

#### Internal Dependencies

```python
deps = [
    "//module:Target",  # Same workspace
]
```

#### External Dependencies (Future)

When external dependencies are needed:

1. **Update WORKSPACE:**
   ```python
   load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

   # Example: rules_jvm_external for Maven dependencies
   http_archive(
       name = "rules_jvm_external",
       # ... configuration
   )
   ```

2. **Use in BUILD files:**
   ```python
   deps = [
       "@maven//:com_google_guava_guava",
   ]
   ```

### Dependency Guidelines

- Keep dependencies minimal
- Use specific versions (avoid version ranges)
- Document why each dependency is needed
- Prefer built-in Java libraries when possible
- Update dependency graphs after changes

## Documentation Standards

### Code Documentation

```java
/**
 * Brief description of the class.
 *
 * <p>Detailed explanation if needed.
 */
public class YourClass {

    /**
     * Description of what this method does.
     *
     * @param param1 description of parameter
     * @return description of return value
     */
    public static String doSomething(String param1) {
        // Implementation
    }
}
```

### BUILD File Documentation

```python
# Brief description of what this target provides
java_library(
    name = "TargetName",
    srcs = glob(["src/main/java/com/acme/arc/dep/test/*.java"]),
    # Made public so other modules can depend on it
    visibility = ["//visibility:public"],
    deps = [
        "//dependency:Target",  # Used for X functionality
    ],
)
```

### Markdown Documentation

- Use clear headings and sections
- Include code examples
- Add commands with expected output
- Keep table of contents updated
- Use relative links for internal docs

## Common Issues

### Build Cache Issues

```bash
# Clear cache if experiencing stale build issues
bazel clean --expunge
```

### Circular Dependencies

If you encounter circular dependency errors:

1. Identify the cycle:
   ```bash
   bazel query 'somepath(//module1:Target1, //module2:Target2)'
   ```

2. Refactor to break the cycle:
   - Extract common code to a new module
   - Move shared interfaces to a separate package
   - Use dependency injection

### Visibility Issues

If you get "target is not visible" errors:

1. Check the target's visibility:
   ```bash
   bazel query //module:Target --output=build | grep visibility
   ```

2. Update BUILD file:
   ```python
   visibility = ["//visibility:public"],
   # Or specific packages:
   visibility = ["//consuming-module:__pkg__"],
   ```

## Resources

### Documentation

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Complete build instructions
- [CLAUDE.md](CLAUDE.md) - Project architecture
- [DEPENDENCY_GRAPHS.md](DEPENDENCY_GRAPHS.md) - Visualization guides
- [Bazel Docs](https://bazel.build/docs) - Official documentation

### Tools

- **Bazel:** https://bazel.build
- **Buildifier:** Format BUILD files (recommended)
- **Graphviz:** Visualize dependency graphs

### Getting Help

1. Check existing documentation
2. Run `bazel help` or `bazel help <command>`
3. Search Bazel documentation
4. Review BUILD files for examples

## License

This project follows the repository's license terms.

---

**Last Updated:** 2026-01-21

