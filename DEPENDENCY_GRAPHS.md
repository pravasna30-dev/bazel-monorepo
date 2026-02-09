# Dependency Graph Files for Miro

This directory contains multiple formats of the monorepo dependency graph that can be imported into Miro.

## Available Formats

### 1. **dependency_graph.png** (Recommended for Miro)
- **Format**: PNG image
- **How to import**:
  1. Open Miro
  2. Click "Upload" or drag and drop the PNG file onto your board
  3. The image will be imported as a static diagram
- **Use case**: Quick visual reference, presentations

### 2. **dependency_graph.svg**
- **Format**: SVG vector graphic
- **How to import**:
  1. Open Miro
  2. Drag and drop the SVG file onto your board
  3. Miro will render it as a scalable vector image
- **Use case**: High-quality diagrams that scale without pixelation

### 3. **dependency_graph.csv**
- **Format**: CSV with Source, Target, Relationship columns
- **How to import**:
  1. In Miro, use the "Import" feature
  2. Select "Import from CSV"
  3. Map columns: Source → From, Target → To, Relationship → Label
  4. Miro will create an interactive diagram
- **Use case**: Creating editable, interactive diagrams in Miro

**CSV Contents:**
```csv
Source,Target,Relationship,Description
TopLevelOne,LowLevelOne,depends on,Java binary depends on Java library
TopLevelOne,Main.java,compiles,Binary compiles this source file
LowLevelOne,LowOneMain.java,compiles,Library compiles this source file
```

### 4. **dependency_graph.json**
- **Format**: JSON with nodes and edges
- **How to use**:
  1. Use Miro's API or plugins that support JSON import
  2. Or convert to another format using scripts
- **Use case**: Programmatic import, automation

### 5. **dependency_graph.mmd**
- **Format**: Mermaid diagram syntax
- **How to use**:
  1. Install a Mermaid plugin for Miro (if available)
  2. Or use [mermaid.live](https://mermaid.live) to render and export as PNG/SVG
  3. Then import the exported image to Miro
- **Use case**: Developer-friendly format, easy to version control

### 6. **dependency_graph_simple.dot**
- **Format**: Graphviz DOT language
- **How to use**:
  1. Use Graphviz to generate other formats
  2. Or use online DOT renderers
  3. Can be edited to customize the diagram
- **Use case**: Customization, generating multiple output formats

### 7. **dependency_graph.dot** (Full Bazel Graph)
- **Format**: Complete Bazel dependency graph including toolchains
- **Warning**: Very large and complex (includes all Bazel internal dependencies)
- **Use case**: Deep debugging, understanding full build dependencies

## Recommended Workflow for Miro

**Option 1 - Quick Import (Easiest):**
1. Use `dependency_graph.png` or `dependency_graph.svg`
2. Drag and drop directly into Miro
3. Position and resize as needed

**Option 2 - Interactive Diagram:**
1. Use `dependency_graph.csv`
2. Import via Miro's CSV import feature
3. Miro will create editable nodes and connectors
4. Customize styling and layout in Miro

**Option 3 - Advanced Customization:**
1. Edit `dependency_graph_simple.dot` to customize
2. Regenerate PNG/SVG using: `dot -Tpng dependency_graph_simple.dot -o custom_graph.png`
3. Import to Miro

## Dependency Structure

```
TopLevelOne (java_binary)
    ├─── depends on ──> LowLevelOne (java_library)
    │                       └─── compiles ──> LowOneMain.java
    └─── compiles ──> Main.java
```

### Node Types:
- **Blue** (TopLevelOne): Java binary - the executable application
- **Orange** (LowLevelOne): Java library - reusable code module
- **Gray**: Source files (.java)

### Relationship Types:
- **Solid thick arrow**: Build dependency (depends on)
- **Dashed arrow**: Compilation relationship (compiles)

## Regenerating Graphs

To regenerate the full Bazel dependency graph:
```bash
bazel query --output=graph 'deps(//...)' > dependency_graph.dot
```

To regenerate PNG/SVG from DOT file:
```bash
dot -Tpng dependency_graph_simple.dot -o dependency_graph.png
dot -Tsvg dependency_graph_simple.dot -o dependency_graph.svg
```

## Tools Required

- **Graphviz** (for DOT file rendering): `brew install graphviz` (macOS)
- **Bazel** (for regenerating): Already installed

