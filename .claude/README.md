# Claude Code Skills for Bazel Monorepo

This directory contains Claude Code skills configuration for this Bazel monorepo.

## Available Skills

### Build Skills
- `/build-all` - Build all targets in the monorepo
- `/build-lib` - Build the low-level-1 library only
- `/build-app` - Build the top-level-1 binary only
- `/clean` - Clean all Bazel build artifacts
- `/clean-all` - Deep clean including external dependencies
- `/rebuild` - Clean and rebuild all targets

### Run Skills
- `/run` - Run the top-level-1 application
- `/quick-check` - Quick build and run to verify everything works

### Test Skills
- `/test-all` - Run all tests in the monorepo
- `/test-lib` - Run tests for low-level-1 library
- `/test-app` - Run tests for top-level-1 application

### Dependency Skills
- `/show-deps` - Generate and display dependency graph (requires graphviz)
- `/analyze-deps` - Analyze dependency structure for a target
- `/deps-graph` - Generate simple dependency graph visualization

### Query Skills
- `/query-targets` - List all targets in the workspace
- `/query-tests` - List all test targets
- `/query-libs` - List all library targets
- `/query-bins` - List all binary targets

### Workspace Skills
- `/info` - Show Bazel workspace information
- `/version` - Show Bazel version
- `/workspace-status` - Show workspace status and configuration
- `/cache-stats` - Show build cache statistics

### Code Quality Skills
- `/format-java` - Format all Java source files (requires google-java-format)

### Documentation Skills
- `/generate-build-docs` - Generate documentation about BUILD files

## Usage Examples

### Quick Build and Run
```
/quick-check
```

### Build Specific Components
```
/build-lib    # Build just the library
/build-app    # Build just the application
```

### Analyze Dependencies
```
/analyze-deps
/analyze-deps --target //top-level-1:TopLevelOne
```

### Generate Dependency Graphs
```
/show-deps     # Generates and opens dependency_graph.png
/deps-graph    # Generates from existing dependency_graph_simple.dot
```

### Clean Builds
```
/clean         # Standard clean
/clean-all     # Deep clean
/rebuild       # Clean and rebuild everything
```

## Prerequisites

Some skills require additional tools:

### For Dependency Visualization
```bash
brew install graphviz
```

### For Java Formatting
```bash
brew install google-java-format
```

## Customization

You can modify `skills.yaml` to:
- Add new skills specific to your workflow
- Customize existing commands
- Add parameters to skills
- Create skill categories

## Skill Structure

Each skill in `skills.yaml` follows this structure:

```yaml
skill-name:
  description: "What this skill does"
  category: "category-name"
  parameters:              # Optional
    - name: param1
      type: string
      description: "Parameter description"
      optional: true
  execution:
    type: command
    command: "command to execute"
```

## Tips

1. **Use Tab Completion**: Type `/` and press Tab to see available skills
2. **Chain Skills**: Combine skills in your instructions to Claude
3. **Add Parameters**: Use `--param value` syntax for skills with parameters
4. **Check Output**: Skills show command output in the terminal

## Common Workflows

### Development Cycle
```
/build-all          # Build everything
/test-all           # Run all tests
/run                # Test the application
```

### Dependency Analysis
```
/show-deps          # Visualize dependencies
/analyze-deps       # List all dependencies
/query-targets      # See all available targets
```

### Clean Slate
```
/clean-all          # Remove all build artifacts
/build-all          # Fresh build
/test-all           # Verify everything works
```

## Troubleshooting

If a skill fails:
1. Check if required tools are installed (graphviz, google-java-format)
2. Verify Bazel is properly configured
3. Check the skill's command in `skills.yaml`
4. Run the underlying Bazel command manually to diagnose

## Learn More

- [Bazel Documentation](https://bazel.build/)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)

