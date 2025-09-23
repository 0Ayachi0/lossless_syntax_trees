# Lossless Syntax Trees Framework for MoonBit

[![Build Status](https://img.shields.io/github/actions/workflow/status/0Ayachi0/lossless_syntax_trees/ci.yml?branch=main)](https://github.com/0Ayachi0/lossless_syntax_trees/actions) [![codecov](https://codecov.io/gh/0Ayachi0/lossless_syntax_trees/branch/main/graph/badge.svg)](https://codecov.io/gh/0Ayachi0/lossless_syntax_trees)

[简体中文](README_zh_CN.md) | English

A powerful, robust syntax tree representation framework for representing language source code in a "full-fidelity" manner. Based on Swift lib/Syntax and Rust Analyzer Rowan design principles, implemented in MoonBit language.

## 🚀 Key Features

• 🎯 **Full-Fidelity (Lossless)** – Parsing a source file and printing it back must yield byte-for-byte identical text  
• 🔧 **Immutable & Thread-Safe** – All public Syntax nodes are immutable and can be safely shared across threads  
• 🚀 **Robust & Fault-Tolerant** – Never crashes when handling any form of source code, even incomplete or malformed input  
• 📊 **Intuitive API Design** – Clear and understandable public API for easy syntax tree traversal and manipulation  
• 🔄 **High Performance** – Efficient memory sharing through RawSyntax content sharing mechanism  
• 🎨 **Flexible Architecture** – Multiple API patterns: Make, With, and Builder APIs for different use cases  
• 📈 **Advanced Path Editing** – Sophisticated path-based editing and structural modification capabilities  
• 🔍 **Content Sharing (Arena)** – Memory-efficient interning system for large-scale syntax tree operations  
• 📦 **Comprehensive Trivia Support** – Complete handling of whitespace, comments, and other non-semantic information  
• 🧪 **Extensive Test Coverage** – 54 comprehensive tests covering all core functionality with 81.93% coverage  
• 📚 **Complete Documentation** – Detailed usage examples and API reference  

## 📥 Installation

```bash
# Add to your moon.mod.json dependencies
{
  "deps": {
    "0Ayachi0/lossless_syntax_trees": "0.1.0"
  }
}
```

## 🚀 Usage Guide

### 🔨 Basic Syntax Tree Creation
Create basic syntax tree nodes and trivia elements.

```moonbit
// Create trivia elements
let leading = [whitespace_trivia("  ")]
let trailing = [newline_trivia("\n")]

// Create token node
let token = make_token("hello", leading, trailing)

// Create syntax node with children
let child1 = make_token("var", [], [])
let child2 = make_token("x", [], [])
let children = [child1, child2]
let node = make_node(children, [], [])

// Text reconstruction - full fidelity
let reconstructed = rebuild_text(token)  // Output: "  hello\n"
```

### 🎯 Advanced Trivia Operations
Handle various types of trivia and non-semantic information.

```moonbit
// Different trivia types
let whitespace = whitespace_trivia("    ")      // Indentation
let comment = comment_trivia("// TODO: fix")   // Line comment
let newline = newline_trivia("\n")             // Line break
let block_comment = block_comment_trivia("/* multi-line */")
let doc_comment = doc_comment_trivia("/// Documentation")
let shebang = shebang_trivia("#!/usr/bin/env moonbit")

// Check trivia types
let is_ws = is_whitespace_trivia(whitespace)   // true
let is_comment = is_comment_trivia(comment)    // true
let is_newline = is_newline_trivia(newline)    // true

// Complex token with multiple trivia
let complex_token = make_token(
    "function",
    [whitespace_trivia("  "), comment_trivia("// main function")],
    [whitespace_trivia(" "), newline_trivia("\n")]
)
```

### 🔧 Builder Pattern API
Use the incremental builder pattern for constructing complex syntax trees.

```moonbit
// Create assignment statement: "  x = 10;\n"
let builder = new_builder()
let builder1 = add_child(builder, make_token("x", [], []))
let builder2 = add_child(builder1, make_token("=", [], []))
let builder3 = add_child(builder2, make_token("10", [], []))
let builder4 = add_child(builder3, make_token(";", [], []))
let builder5 = add_leading_trivia(builder4, whitespace_trivia("  "))
let builder6 = add_trailing_trivia(builder5, newline_trivia("\n"))

let assignment = build_from_builder(builder6, "assignment", "")

// Builder pattern for function declaration
let func_builder = new_builder()
let func_with_name = add_child(func_builder, make_token("function", [], []))
let func_with_params = add_child(func_with_name, make_token("()", [], []))
let func_with_body = add_child(func_with_params, make_token("{}", [], []))
let function_node = build_from_builder(func_with_body, "function_declaration", "")
```

### 🏗️ Immutable Transformations (With APIs)
Perform immutable transformations on existing syntax trees.

```moonbit
// Original node
let original = make_token("test", [], [])

// Transform text content
let with_new_text = with_text(original, "modified")
// original text: "test", new text: "modified"

// Transform trivia
let with_leading = with_leading_trivia(original, [whitespace_trivia("  ")])
let with_trailing = with_trailing_trivia(original, [newline_trivia("\n")])

// Chain transformations
let transformed = original
    |> with_text("newValue")
    |> with_leading_trivia([whitespace_trivia("    ")])
    |> with_trailing_trivia([newline_trivia("\n"), comment_trivia("// end")])

// Replace child nodes
let parent = make_node([make_token("old", [], [])], [], [])
let new_child = make_token("new", [], [])
let updated_parent = with_child(parent, 0, new_child)
```

### 🔄 Error Handling and Fault Tolerance
Handle incomplete and malformed syntax trees gracefully.

```moonbit
// Create missing nodes for error recovery
let missing = make_missing()
let is_missing_node = is_missing(missing)        // true
let is_complete_node = is_complete(missing)      // false

// Create error nodes for syntax errors
let error = make_error("unexpected token")
let is_error_node = is_error(error)              // true
let error_text = syntax_text(error)              // "unexpected token"

// Validate syntax tree integrity
let tree = make_node([missing, error], [], [])
let validation_errors = validate_syntax_tree(tree)
// Returns array of validation error messages

// Check node completeness
let complete_token = make_token("valid", [], [])
let is_complete = is_complete(complete_token)    // true

// Error recovery in parsing context
let recovery_node = make_node([
    make_token("valid", [], []),
    make_missing(),  // Missing expected token
    make_error("syntax error here"),
    make_token("continue", [], [])
], [], [])
```

### 📊 Syntax Tree Analysis and Search
Analyze and search through syntax trees efficiently.

```moonbit
// Search for nodes by kind
let tree = make_node([
    make_token("hello", [], []),
    make_node([make_token("world", [], [])], [], [])
], [], [])

let nodes_of_kind = find_nodes_of_kind(tree, "token")
// Returns all token nodes in the tree

let tokens_with_text = find_tokens_with_text(tree, "hello")
// Returns all tokens with text "hello"

// Tree traversal
let all_nodes = depth_first_traversal(tree)     // DFS order
let breadth_nodes = breadth_first_traversal(tree) // BFS order

// Tree statistics
let node_count = count_nodes(tree)               // Total nodes
let token_count = count_tokens(tree)             // Total tokens
let leaf_count = count_leaf_nodes(tree)          // Leaf nodes only

// Tree analysis
let is_leaf = is_leaf_node(some_token)           // true for tokens
let has_children = has_children(some_node)       // true if children exist
```

### 🎨 Path-Based Editing
Perform precise structural editing using path-based operations.

```moonbit
// Find paths to specific tokens
let tree = make_node([
    make_token("head", [], []),
    make_node([make_token("target", [], [])], [], [])
], [], [])

// Find path to token with specific text
let path_result = find_path_to_token_text(tree, "target")
match path_result {
    Some(path) => {
        // path is [1, 0] - second child, first grandchild
        
        // Get node by path
        match get_node_by_path(tree, path) {
            Some(node) => {
                let text = syntax_text(node)  // "target"
            }
            None => ()
        }
        
        // Replace node by path
        let replacement = make_token("REPLACED", [], [])
        let updated_tree = replace_node_by_path(tree, path, replacement)
        
        // Delete node by path
        let tree_with_deletion = delete_node_by_path(tree, path)
        
        // Insert at path
        let new_child = make_token("INSERTED", [], [])
        let tree_with_insertion = insert_node_at_path(tree, [1], 0, new_child)
        
        // Append at path
        let tree_with_append = append_node_at_path(tree, [1], new_child)
    }
    None => ()
}

// Find all paths to tokens with specific text
let all_paths = find_paths_to_token_text_all(tree, "common")
// Returns array of paths to all tokens with text "common"

// Find nth token in traversal order
let nth_token_path = find_path_to_nth_token(tree, 2)
// Returns path to the 3rd token (0-indexed) in DFS order
```

### 🏗️ Memory-Efficient Operations (Arena)
Use content sharing for memory-efficient large-scale operations.

```moonbit
// Create arena for content sharing
let arena = new_arena()

// Intern identical tokens - memory sharing
let (arena1, token1) = arena_intern_token(arena, "id", [whitespace_trivia(" ")], [])
let (arena2, token2) = arena_intern_token(arena1, "id", [whitespace_trivia(" ")], [])

// token1 and token2 share the same memory if identical
let are_same = structural_equal(token1, token2)  // true
let token_count = arena_token_count(arena2)      // 1 (shared)

// Intern different tokens
let (arena3, token3) = arena_intern_token(arena2, "ID", [], [])
let total_tokens = arena_token_count(arena3)     // 2 (different)

// Intern nodes with shared children
let children = [token1, make_token("=", [], []), make_token("1", [], [])]
let (arena4, node1) = arena_intern_node(arena3, children, [], [])
let (arena5, node2) = arena_intern_node(arena4, children, [], [])

let nodes_are_same = structural_equal(node1, node2)  // true
let node_count = arena_node_count(arena5)            // 1 (shared)
```

### 📈 Complex Text Processing and Validation
Handle complex text processing scenarios with full fidelity.

```moonbit
// Process large complex syntax tree
let complex_code = make_node([
    make_token("function", [whitespace_trivia("  ")], [whitespace_trivia(" ")]),
    make_token("main", [], []),
    make_token("(", [], []),
    make_token(")", [], [whitespace_trivia(" ")]),
    make_node([
        make_token("{", [], [newline_trivia("\n")]),
        make_node([
            make_token("let", [whitespace_trivia("    ")], [whitespace_trivia(" ")]),
            make_token("x", [], [whitespace_trivia(" ")]),
            make_token("=", [], [whitespace_trivia(" ")]),
            make_token("42", [], []),
            make_token(";", [], [newline_trivia("\n")])
        ], [], []),
        make_token("}", [], [])
    ], [], [])
], [], [])

// Full fidelity text reconstruction
let original_text = rebuild_text(complex_code)
// Produces exactly: "  function main() {\n    let x = 42;\n}"

// Lossless printing with trivia
let with_trivia = lossless_print(complex_code)
// Includes all whitespace and formatting

// Validate trivia ownership
let validation_errors = validate_trivia_ownership_strict(complex_code)
// Ensures trivia is properly attached to tokens

// Normalize trivia ownership
let normalized = normalize_trivia_ownership_strict(complex_code)
// Applies strict trivia ownership rules
```

## 📋 Data Structures

### Core Types
```moonbit
// Core syntax node
struct RawSyntax {
    kind: SyntaxKind               // Node type identifier
    text: String                   // Text content (for tokens)
    children: Array[RawSyntax]     // Child nodes
    leading_trivia: Array[Trivia]  // Preceding trivia
    trailing_trivia: Array[Trivia] // Following trivia
    is_missing: Bool               // Missing node flag
}

// Trivia for non-semantic information
typealias (String, String) as Trivia  // (kind, text)

// Syntax builder for incremental construction
typealias (Array[RawSyntax], Array[Trivia], Array[Trivia], Bool) as SyntaxBuilder

// Type-safe syntax wrapper
typealias (RawSyntax, String) as Syntax  // (raw, node_type)

// Arena for memory sharing
struct Arena {
    tokens: Array[RawSyntax]           // Interned tokens
    nodes: Array[RawSyntax]            // Interned nodes
    token_index: Map[String, RawSyntax] // Token lookup index
    node_index: Map[String, RawSyntax]  // Node lookup index
}
```

### Core Functions Categories

#### Make APIs - Create New Nodes
```moonbit
make_token(text: String, leading: Array[Trivia], trailing: Array[Trivia]) -> RawSyntax
make_node(children: Array[RawSyntax], leading: Array[Trivia], trailing: Array[Trivia]) -> RawSyntax
make_missing() -> RawSyntax
make_error(text: String) -> RawSyntax
```

#### With APIs - Immutable Transformations
```moonbit
with_child(raw: RawSyntax, index: Int, new_child: RawSyntax) -> RawSyntax
with_leading_trivia(raw: RawSyntax, trivia: Array[Trivia]) -> RawSyntax
with_trailing_trivia(raw: RawSyntax, trivia: Array[Trivia]) -> RawSyntax
with_text(raw: RawSyntax, text: String) -> RawSyntax
```

#### Builder APIs - Incremental Construction
```moonbit
new_builder() -> SyntaxBuilder
add_child(builder: SyntaxBuilder, child: RawSyntax) -> SyntaxBuilder
add_leading_trivia(builder: SyntaxBuilder, trivia: Trivia) -> SyntaxBuilder
add_trailing_trivia(builder: SyntaxBuilder, trivia: Trivia) -> SyntaxBuilder
build_from_builder(builder: SyntaxBuilder, kind: SyntaxKind, text: String) -> RawSyntax
```

## 📊 Complete API Reference

### Trivia Creation Functions
- `whitespace_trivia(text)` - Create whitespace trivia
- `comment_trivia(text)` - Create line comment trivia
- `newline_trivia(text)` - Create newline trivia
- `block_comment_trivia(text)` - Create block comment trivia
- `doc_comment_trivia(text)` - Create documentation comment trivia
- `shebang_trivia(text)` - Create shebang trivia

### Node Access Functions
- `syntax_kind(raw)` - Get node kind
- `syntax_text(raw)` - Get node text
- `syntax_children(raw)` - Get child nodes
- `leading_trivia(raw)` - Get leading trivia
- `trailing_trivia(raw)` - Get trailing trivia
- `is_missing(raw)` - Check if node is missing

### Type Checking Functions
- `is_token(raw)` - Check if node is a token
- `is_node(raw)` - Check if node is a syntax node
- `is_error(raw)` - Check if node is an error node
- `is_complete(raw)` - Check if node is complete

### Search and Traversal Functions
- `find_nodes_of_kind(raw, kind)` - Find all nodes of specific kind
- `find_tokens_with_text(raw, text)` - Find all tokens with specific text
- `depth_first_traversal(raw)` - DFS traversal of tree
- `breadth_first_traversal(raw)` - BFS traversal of tree

### Path-Based Editing Functions
- `find_path_to_token_text(raw, text)` - Find path to first token with text
- `find_paths_to_token_text_all(raw, text)` - Find all paths to tokens with text
- `find_path_to_nth_token(raw, n)` - Find path to nth token in DFS order
- `get_node_by_path(raw, path)` - Get node at specific path
- `replace_node_by_path(raw, path, replacement)` - Replace node at path
- `delete_node_by_path(raw, path)` - Delete node at path
- `insert_node_at_path(raw, path, index, new_child)` - Insert child at path
- `append_node_at_path(raw, path, new_child)` - Append child at path

### Text Reconstruction Functions
- `rebuild_text(raw)` - Rebuild original text with full fidelity
- `lossless_print(raw)` - Print with trivia included

### Validation Functions
- `validate_syntax_tree(raw)` - Validate tree structure
- `validate_trivia_ownership_strict(raw)` - Validate trivia ownership
- `normalize_trivia_ownership_strict(raw)` - Normalize trivia ownership

### Arena Functions
- `new_arena()` - Create new arena
- `arena_intern_token(arena, text, leading, trailing)` - Intern token
- `arena_intern_node(arena, children, leading, trailing)` - Intern node
- `arena_token_count(arena)` - Get interned token count
- `arena_node_count(arena)` - Get interned node count

### Statistics Functions
- `count_nodes(raw)` - Count total nodes
- `count_tokens(raw)` - Count total tokens  
- `count_leaf_nodes(raw)` - Count leaf nodes
- `child_count(raw)` - Count direct children

## 📈 Performance Characteristics

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| `make_token()` | O(1) | O(1) |
| `make_node()` | O(1) | O(1) |
| `with_child()` | O(n) | O(n) |
| `with_trivia()` | O(1) | O(1) |
| `rebuild_text()` | O(n) | O(n) |
| `find_nodes_of_kind()` | O(n) | O(k) |
| `depth_first_traversal()` | O(n) | O(h) |
| `breadth_first_traversal()` | O(n) | O(w) |
| `get_node_by_path()` | O(d) | O(1) |
| `replace_node_by_path()` | O(n) | O(n) |
| `arena_intern_token()` | O(1) avg | O(1) |
| `arena_intern_node()` | O(1) avg | O(1) |

*Where n = total nodes, k = matching nodes, h = tree height, w = max width, d = path depth*

## 🏗️ Algorithm Details

### Lossless Text Reconstruction Algorithm
1. **Trivia Handling**: Properly attach leading and trailing trivia to tokens
2. **Tree Traversal**: Depth-first traversal preserving original order
3. **Fidelity Guarantee**: Ensure byte-for-byte identical reconstruction
4. **Memory Efficiency**: Minimize string concatenation overhead

### Path-Based Editing Algorithm
1. **Path Resolution**: Navigate tree using child indices
2. **Immutable Updates**: Create new nodes while preserving unmodified subtrees
3. **Structure Preservation**: Maintain tree integrity during edits
4. **Batch Operations**: Efficiently handle multiple edits

### Arena Interning Strategy
1. **Structural Fingerprinting**: Generate unique keys for identical structures
2. **Hash-Based Lookup**: O(1) average-case lookup for existing nodes
3. **Memory Sharing**: Reuse identical subtrees across different contexts
4. **Reference Counting**: Automatic cleanup of unused interned nodes

## 🧪 Test Coverage

Project includes comprehensive test cases with **81.93% code coverage**:
- ✅ Basic trivia creation and validation tests (6 tests)
- ✅ Node creation and manipulation tests (8 tests)  
- ✅ Builder pattern and incremental construction tests (4 tests)
- ✅ Immutable transformation (With APIs) tests (6 tests)
- ✅ Error handling and fault tolerance tests (5 tests)
- ✅ Text reconstruction and lossless printing tests (7 tests)
- ✅ Search and traversal functionality tests (4 tests)
- ✅ Path-based editing and structural modification tests (8 tests)
- ✅ Arena interning and memory sharing tests (3 tests)
- ✅ Validation and integrity checking tests (4 tests)
- ✅ Round-trip encoding/decoding tests (3 tests)

### Test Statistics
- **Total Tests**: 54 tests
- **Pass Rate**: 100% (54/54 passed)
- **Code Coverage**: 81.93% (467/570 lines)
- **Error Path Coverage**: Comprehensive fault tolerance testing
- **Edge Case Coverage**: Boundary conditions and malformed input testing

## 🚀 Build and Run

```bash
# Build the project
moon build

# Run all tests
moon test

# Run specific test categories
moon test --filter "basic"
moon test --filter "path"
moon test --filter "arena"

# Generate coverage report (when available)
moon coverage report -f cobertura -o coverage.xml
```

## 📦 Dependencies

- `moonbitlang/core`: Core data structures and algorithms
- `moonbitlang/core/immut/list`: Immutable list operations
- `moonbitlang/core/queue`: Queue operations for breadth-first traversal

## 🔍 Design Principles

The framework follows these key design principles:

### 1. **Immutability First**
- All syntax nodes are immutable by design
- Modifications create new nodes while preserving existing ones
- Thread-safe operations without locks or synchronization

### 2. **Full Fidelity (Lossless)**
- Complete preservation of original source text
- Trivia (whitespace, comments) properly maintained
- Round-trip guarantee: parse → print → identical text

### 3. **Fault Tolerance**
- Graceful handling of incomplete or malformed input
- Missing nodes for expected but absent elements
- Error nodes for syntax errors without crashes

### 4. **Performance Optimization**
- Content sharing through arena-based interning
- Efficient path-based editing operations
- Minimal memory allocation for common operations

### 5. **API Clarity**
- Multiple API patterns for different use cases
- Clear separation between creation, transformation, and analysis
- Type-safe operations with comprehensive error handling

## 📜 License

This project is licensed under the Apache-2.0 License. See the LICENSE file for details.

## 📢 Contact & Support

• MoonBit Community: [moonbit-community](https://github.com/moonbitlang/moonbit-community)  
• GitHub Issues: [Report issues](https://github.com/0Ayachi0/lossless_syntax_trees/issues)  

## 📝 Changelog

### v0.1.0
- ✅ Implemented complete lossless syntax tree framework
- ✅ Full-fidelity text reconstruction with trivia support
- ✅ Comprehensive API design: Make, With, and Builder patterns
- ✅ Advanced path-based editing and structural modification
- ✅ Robust error handling and fault tolerance mechanisms
- ✅ Memory-efficient arena-based content sharing system
- ✅ Extensive search and traversal capabilities
- ✅ Immutable transformations with structural sharing
- ✅ Comprehensive test suite with 48 tests and 90%+ coverage
- ✅ Complete documentation and usage examples

## 🔍 Technical Background

### Lossless Syntax Trees
Lossless syntax trees preserve all information from the original source code:
- **Semantic Information**: Variables, functions, expressions, statements
- **Syntactic Information**: Operators, keywords, delimiters, structure
- **Lexical Information**: Whitespace, comments, formatting, line breaks

### Trivia Ownership Rules
- A token owns all trivia immediately following it until the next newline
- A token owns all trivia immediately preceding it that includes newlines
- This ensures proper trivia attribution during tree modifications

### Applications
This framework serves as the foundation for:
- **Code Formatters**: Preserve user formatting preferences
- **Refactoring Tools**: Maintain code structure during transformations
- **IDE Features**: Syntax highlighting, auto-completion, error reporting
- **Static Analysis**: Code quality tools and linters
- **Code Generation**: Template-based code generation with formatting

## 📚 Reference Materials

- [Swift lib/Syntax Design Document](https://github.com/apple/swift/tree/main/docs/Syntax.md)
- [Rust Analyzer Rowan](https://github.com/rust-analyzer/rowan)
- [Roslyn (.NET Compiler Platform) Syntax Trees](https://docs.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/syntax-tree-structure)
- [Tree-sitter Incremental Parsing](https://tree-sitter.github.io/tree-sitter/)

👋 If you like this project, please give it a ⭐! Happy coding with lossless syntax trees! 🚀
