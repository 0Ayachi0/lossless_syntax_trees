# MoonBit 无损语法树框架

[![构建状态](https://img.shields.io/github/actions/workflow/status/0Ayachi0/lossless_syntax_trees/ci.yml?branch=main)](https://github.com/0Ayachi0/lossless_syntax_trees/actions) [![codecov](https://codecov.io/gh/0Ayachi0/lossless_syntax_trees/branch/main/graph/badge.svg)](https://codecov.io/gh/0Ayachi0/lossless_syntax_trees)

简体中文 | [English](README.md)

一个强大、健壮的语法树表示框架，用于以"全保真"（full-fidelity）的方式表示语言源代码。该框架基于Swift lib/Syntax和Rust Analyzer Rowan的设计思想，使用MoonBit语言实现。

## 🚀 核心特性

• 🎯 **全保真 (无损)** – 解析源文件并打印输出必须产生逐字节相同的文本  
• 🔧 **不可变与线程安全** – 所有公开的Syntax节点都是不可变的，可以安全地跨线程共享  
• 🚀 **健壮与容错** – 处理任何形式的源代码（甚至不完整或格式错误的输入）时绝不崩溃  
• 📊 **直观的API设计** – 清晰易懂的公共API，便于语法树遍历和操作  
• 🔄 **高性能** – 通过RawSyntax内容共享机制实现高效的内存共享  
• 🎨 **灵活架构** – 多种API模式：Make、With和Builder API适用于不同场景  
• 📈 **高级路径编辑** – 复杂的基于路径的编辑和结构修改功能  
• 🔍 **内容共享 (Arena)** – 针对大规模语法树操作的内存高效驻留系统  
• 📦 **全面的Trivia支持** – 完整处理空白字符、注释和其他非语义信息  
• 🧪 **广泛的测试覆盖** – 54个综合测试覆盖所有核心功能，测试覆盖率81.93%  
• 📚 **完整文档** – 详细的使用示例和API参考  

## 📥 安装

```bash
# 添加到您的 moon.mod.json 依赖中
{
  "deps": {
    "0Ayachi0/lossless_syntax_trees": "0.1.0"
  }
}
```

## 🚀 使用指南

### 🔨 基础语法树创建
创建基本的语法树节点和trivia元素。

```moonbit
// 创建trivia元素
let leading = [whitespace_trivia("  ")]
let trailing = [newline_trivia("\n")]

// 创建token节点
let token = make_token("hello", leading, trailing)

// 创建带子节点的语法节点
let child1 = make_token("var", [], [])
let child2 = make_token("x", [], [])
let children = [child1, child2]
let node = make_node(children, [], [])

// 文本重建 - 全保真
let reconstructed = rebuild_text(token)  // 输出: "  hello\n"
```

### 🎯 高级Trivia操作
处理各种类型的trivia和非语义信息。

```moonbit
// 不同的trivia类型
let whitespace = whitespace_trivia("    ")      // 缩进
let comment = comment_trivia("// TODO: 修复")   // 行注释
let newline = newline_trivia("\n")             // 换行符
let block_comment = block_comment_trivia("/* 多行注释 */")
let doc_comment = doc_comment_trivia("/// 文档注释")
let shebang = shebang_trivia("#!/usr/bin/env moonbit")

// 检查trivia类型
let is_ws = is_whitespace_trivia(whitespace)   // true
let is_comment = is_comment_trivia(comment)    // true
let is_newline = is_newline_trivia(newline)    // true

// 带有多个trivia的复杂token
let complex_token = make_token(
    "function",
    [whitespace_trivia("  "), comment_trivia("// 主函数")],
    [whitespace_trivia(" "), newline_trivia("\n")]
)
```

### 🔧 构建器模式API
使用增量构建器模式构造复杂的语法树。

```moonbit
// 创建赋值语句: "  x = 10;\n"
let builder = new_builder()
let builder1 = add_child(builder, make_token("x", [], []))
let builder2 = add_child(builder1, make_token("=", [], []))
let builder3 = add_child(builder2, make_token("10", [], []))
let builder4 = add_child(builder3, make_token(";", [], []))
let builder5 = add_leading_trivia(builder4, whitespace_trivia("  "))
let builder6 = add_trailing_trivia(builder5, newline_trivia("\n"))

let assignment = build_from_builder(builder6, "assignment", "")

// 函数声明的构建器模式
let func_builder = new_builder()
let func_with_name = add_child(func_builder, make_token("function", [], []))
let func_with_params = add_child(func_with_name, make_token("()", [], []))
let func_with_body = add_child(func_with_params, make_token("{}", [], []))
let function_node = build_from_builder(func_with_body, "function_declaration", "")
```

### 🏗️ 不可变转换 (With APIs)
对现有语法树执行不可变转换。

```moonbit
// 原始节点
let original = make_token("test", [], [])

// 转换文本内容
let with_new_text = with_text(original, "modified")
// 原始文本: "test", 新文本: "modified"

// 转换trivia
let with_leading = with_leading_trivia(original, [whitespace_trivia("  ")])
let with_trailing = with_trailing_trivia(original, [newline_trivia("\n")])

// 链式转换
let transformed = original
    |> with_text("newValue")
    |> with_leading_trivia([whitespace_trivia("    ")])
    |> with_trailing_trivia([newline_trivia("\n"), comment_trivia("// 结束")])

// 替换子节点
let parent = make_node([make_token("old", [], [])], [], [])
let new_child = make_token("new", [], [])
let updated_parent = with_child(parent, 0, new_child)
```

### 🔄 错误处理和容错能力
优雅地处理不完整和格式错误的语法树。

```moonbit
// 为错误恢复创建缺失节点
let missing = make_missing()
let is_missing_node = is_missing(missing)        // true
let is_complete_node = is_complete(missing)      // false

// 为语法错误创建错误节点
let error = make_error("意外的token")
let is_error_node = is_error(error)              // true
let error_text = syntax_text(error)              // "意外的token"

// 验证语法树完整性
let tree = make_node([missing, error], [], [])
let validation_errors = validate_syntax_tree(tree)
// 返回验证错误消息数组

// 检查节点完整性
let complete_token = make_token("valid", [], [])
let is_complete = is_complete(complete_token)    // true

// 解析上下文中的错误恢复
let recovery_node = make_node([
    make_token("valid", [], []),
    make_missing(),  // 缺失的预期token
    make_error("这里有语法错误"),
    make_token("continue", [], [])
], [], [])
```

### 📊 语法树分析和搜索
高效地分析和搜索语法树。

```moonbit
// 按类型搜索节点
let tree = make_node([
    make_token("hello", [], []),
    make_node([make_token("world", [], [])], [], [])
], [], [])

let nodes_of_kind = find_nodes_of_kind(tree, "token")
// 返回树中所有token节点

let tokens_with_text = find_tokens_with_text(tree, "hello")
// 返回所有文本为"hello"的token

// 树遍历
let all_nodes = depth_first_traversal(tree)     // DFS顺序
let breadth_nodes = breadth_first_traversal(tree) // BFS顺序

// 树统计
let node_count = count_nodes(tree)               // 总节点数
let token_count = count_tokens(tree)             // 总token数
let leaf_count = count_leaf_nodes(tree)          // 仅叶节点

// 树分析
let is_leaf = is_leaf_node(some_token)           // token为true
let has_children = has_children(some_node)       // 有子节点时为true
```

### 🎨 基于路径的编辑
使用基于路径的操作执行精确的结构编辑。

```moonbit
// 查找特定token的路径
let tree = make_node([
    make_token("head", [], []),
    make_node([make_token("target", [], [])], [], [])
], [], [])

// 查找具有特定文本的token路径
let path_result = find_path_to_token_text(tree, "target")
match path_result {
    Some(path) => {
        // path是[1, 0] - 第二个子节点，第一个孙节点
        
        // 按路径获取节点
        match get_node_by_path(tree, path) {
            Some(node) => {
                let text = syntax_text(node)  // "target"
            }
            None => ()
        }
        
        // 按路径替换节点
        let replacement = make_token("REPLACED", [], [])
        let updated_tree = replace_node_by_path(tree, path, replacement)
        
        // 按路径删除节点
        let tree_with_deletion = delete_node_by_path(tree, path)
        
        // 在路径处插入
        let new_child = make_token("INSERTED", [], [])
        let tree_with_insertion = insert_node_at_path(tree, [1], 0, new_child)
        
        // 在路径处追加
        let tree_with_append = append_node_at_path(tree, [1], new_child)
    }
    None => ()
}

// 查找所有具有特定文本的token路径
let all_paths = find_paths_to_token_text_all(tree, "common")
// 返回所有文本为"common"的token路径数组

// 查找遍历顺序中的第n个token
let nth_token_path = find_path_to_nth_token(tree, 2)
// 返回DFS顺序中第3个token（0索引）的路径
```

### 🏗️ 内存高效操作 (Arena)
使用内容共享进行内存高效的大规模操作。

```moonbit
// 为内容共享创建arena
let arena = new_arena()

// 驻留相同的token - 内存共享
let (arena1, token1) = arena_intern_token(arena, "id", [whitespace_trivia(" ")], [])
let (arena2, token2) = arena_intern_token(arena1, "id", [whitespace_trivia(" ")], [])

// 如果相同，token1和token2共享相同内存
let are_same = structural_equal(token1, token2)  // true
let token_count = arena_token_count(arena2)      // 1 (共享)

// 驻留不同的token
let (arena3, token3) = arena_intern_token(arena2, "ID", [], [])
let total_tokens = arena_token_count(arena3)     // 2 (不同)

// 驻留带有共享子节点的节点
let children = [token1, make_token("=", [], []), make_token("1", [], [])]
let (arena4, node1) = arena_intern_node(arena3, children, [], [])
let (arena5, node2) = arena_intern_node(arena4, children, [], [])

let nodes_are_same = structural_equal(node1, node2)  // true
let node_count = arena_node_count(arena5)            // 1 (共享)
```

### 📈 复杂文本处理和验证
以全保真方式处理复杂的文本处理场景。

```moonbit
// 处理大型复杂语法树
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

// 全保真文本重建
let original_text = rebuild_text(complex_code)
// 精确生成: "  function main() {\n    let x = 42;\n}"

// 带trivia的无损打印
let with_trivia = lossless_print(complex_code)
// 包含所有空白字符和格式

// 验证trivia所有权
let validation_errors = validate_trivia_ownership_strict(complex_code)
// 确保trivia正确附加到token

// 规范化trivia所有权
let normalized = normalize_trivia_ownership_strict(complex_code)
// 应用严格的trivia所有权规则
```

## 📋 数据结构

### 核心类型
```moonbit
// 核心语法节点
struct RawSyntax {
    kind: SyntaxKind               // 节点类型标识符
    text: String                   // 文本内容（用于token）
    children: Array[RawSyntax]     // 子节点
    leading_trivia: Array[Trivia]  // 前导trivia
    trailing_trivia: Array[Trivia] // 后置trivia
    is_missing: Bool               // 缺失节点标志
}

// 非语义信息的Trivia
typealias (String, String) as Trivia  // (类型, 文本)

// 增量构建的语法构建器
typealias (Array[RawSyntax], Array[Trivia], Array[Trivia], Bool) as SyntaxBuilder

// 类型安全的语法包装器
typealias (RawSyntax, String) as Syntax  // (raw, node_type)

// 内存共享的Arena
struct Arena {
    tokens: Array[RawSyntax]           // 驻留的token
    nodes: Array[RawSyntax]            // 驻留的节点
    token_index: Map[String, RawSyntax] // Token查找索引
    node_index: Map[String, RawSyntax]  // 节点查找索引
}
```

### 核心函数分类

#### Make APIs - 创建新节点
```moonbit
make_token(text: String, leading: Array[Trivia], trailing: Array[Trivia]) -> RawSyntax
make_node(children: Array[RawSyntax], leading: Array[Trivia], trailing: Array[Trivia]) -> RawSyntax
make_missing() -> RawSyntax
make_error(text: String) -> RawSyntax
```

#### With APIs - 不可变转换
```moonbit
with_child(raw: RawSyntax, index: Int, new_child: RawSyntax) -> RawSyntax
with_leading_trivia(raw: RawSyntax, trivia: Array[Trivia]) -> RawSyntax
with_trailing_trivia(raw: RawSyntax, trivia: Array[Trivia]) -> RawSyntax
with_text(raw: RawSyntax, text: String) -> RawSyntax
```

#### Builder APIs - 增量构建
```moonbit
new_builder() -> SyntaxBuilder
add_child(builder: SyntaxBuilder, child: RawSyntax) -> SyntaxBuilder
add_leading_trivia(builder: SyntaxBuilder, trivia: Trivia) -> SyntaxBuilder
add_trailing_trivia(builder: SyntaxBuilder, trivia: Trivia) -> SyntaxBuilder
build_from_builder(builder: SyntaxBuilder, kind: SyntaxKind, text: String) -> RawSyntax
```

## 📊 完整API参考

### Trivia创建函数
- `whitespace_trivia(text)` - 创建空白字符trivia
- `comment_trivia(text)` - 创建行注释trivia
- `newline_trivia(text)` - 创建换行trivia
- `block_comment_trivia(text)` - 创建块注释trivia
- `doc_comment_trivia(text)` - 创建文档注释trivia
- `shebang_trivia(text)` - 创建shebang trivia

### 节点访问函数
- `syntax_kind(raw)` - 获取节点类型
- `syntax_text(raw)` - 获取节点文本
- `syntax_children(raw)` - 获取子节点
- `leading_trivia(raw)` - 获取前导trivia
- `trailing_trivia(raw)` - 获取后置trivia
- `is_missing(raw)` - 检查节点是否缺失

### 类型检查函数
- `is_token(raw)` - 检查节点是否为token
- `is_node(raw)` - 检查节点是否为语法节点
- `is_error(raw)` - 检查节点是否为错误节点
- `is_complete(raw)` - 检查节点是否完整

### 搜索和遍历函数
- `find_nodes_of_kind(raw, kind)` - 查找特定类型的所有节点
- `find_tokens_with_text(raw, text)` - 查找特定文本的所有token
- `depth_first_traversal(raw)` - 树的DFS遍历
- `breadth_first_traversal(raw)` - 树的BFS遍历

### 基于路径的编辑函数
- `find_path_to_token_text(raw, text)` - 查找第一个具有指定文本的token路径
- `find_paths_to_token_text_all(raw, text)` - 查找所有具有指定文本的token路径
- `find_path_to_nth_token(raw, n)` - 查找DFS顺序中第n个token的路径
- `get_node_by_path(raw, path)` - 获取指定路径的节点
- `replace_node_by_path(raw, path, replacement)` - 替换路径处的节点
- `delete_node_by_path(raw, path)` - 删除路径处的节点
- `insert_node_at_path(raw, path, index, new_child)` - 在路径处插入子节点
- `append_node_at_path(raw, path, new_child)` - 在路径处追加子节点

### 文本重建函数
- `rebuild_text(raw)` - 全保真重建原始文本
- `lossless_print(raw)` - 包含trivia的打印

### 验证函数
- `validate_syntax_tree(raw)` - 验证树结构
- `validate_trivia_ownership_strict(raw)` - 验证trivia所有权
- `normalize_trivia_ownership_strict(raw)` - 规范化trivia所有权

### Arena函数
- `new_arena()` - 创建新arena
- `arena_intern_token(arena, text, leading, trailing)` - 驻留token
- `arena_intern_node(arena, children, leading, trailing)` - 驻留节点
- `arena_token_count(arena)` - 获取驻留token数量
- `arena_node_count(arena)` - 获取驻留节点数量

### 统计函数
- `count_nodes(raw)` - 计算总节点数
- `count_tokens(raw)` - 计算总token数
- `count_leaf_nodes(raw)` - 计算叶节点数
- `child_count(raw)` - 计算直接子节点数

## 📈 性能特征

| 操作 | 时间复杂度 | 空间复杂度 |
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
| `arena_intern_token()` | O(1) 平均 | O(1) |
| `arena_intern_node()` | O(1) 平均 | O(1) |

*其中 n = 总节点数，k = 匹配节点数，h = 树高度，w = 最大宽度，d = 路径深度*

## 🏗️ 算法详情

### 无损文本重建算法
1. **Trivia处理**: 正确地将前导和后置trivia附加到token
2. **树遍历**: 深度优先遍历保持原始顺序
3. **保真保证**: 确保逐字节相同的重建
4. **内存效率**: 最小化字符串连接开销

### 基于路径的编辑算法
1. **路径解析**: 使用子索引导航树
2. **不可变更新**: 创建新节点同时保留未修改的子树
3. **结构保持**: 在编辑期间维护树的完整性
4. **批处理操作**: 高效处理多个编辑

### Arena驻留策略
1. **结构指纹**: 为相同结构生成唯一键
2. **基于哈希的查找**: 平均O(1)查找现有节点
3. **内存共享**: 在不同上下文中重用相同的子树
4. **引用计数**: 自动清理未使用的驻留节点

## 🧪 测试覆盖

项目包含全面的测试用例，**测试覆盖率81.93%**：
- ✅ 基础trivia创建和验证测试 (6个测试)
- ✅ 节点创建和操作测试 (8个测试)
- ✅ 构建器模式和增量构建测试 (4个测试)
- ✅ 不可变转换 (With APIs) 测试 (6个测试)
- ✅ 错误处理和容错测试 (5个测试)
- ✅ 文本重建和无损打印测试 (7个测试)
- ✅ 搜索和遍历功能测试 (4个测试)
- ✅ 基于路径的编辑和结构修改测试 (8个测试)
- ✅ Arena驻留和内存共享测试 (3个测试)
- ✅ 验证和完整性检查测试 (4个测试)
- ✅ 往返编码/解码测试 (3个测试)

### 测试统计
- **总测试数**: 54个测试
- **通过率**: 100% (54/54 通过)
- **代码覆盖率**: 81.93% (467/570 行)
- **错误路径覆盖**: 全面的容错测试
- **边缘情况覆盖**: 边界条件和格式错误输入测试

## 🚀 构建和运行

```bash
# 构建项目
moon build

# 运行所有测试
moon test

# 运行特定测试类别
moon test --filter "basic"
moon test --filter "path"
moon test --filter "arena"

# 生成覆盖率报告 (可用时)
moon coverage report -f cobertura -o coverage.xml
```

## 📦 依赖

- `moonbitlang/core`: 核心数据结构和算法
- `moonbitlang/core/immut/list`: 不可变列表操作
- `moonbitlang/core/queue`: 广度优先遍历的队列操作

## 🔍 设计原则

该框架遵循以下关键设计原则：

### 1. **不可变性优先**
- 所有语法节点都是不可变设计
- 修改创建新节点同时保留现有节点
- 无需锁或同步的线程安全操作

### 2. **全保真 (无损)**
- 完整保留原始源文本
- 正确维护Trivia（空白字符、注释）
- 往返保证：解析 → 打印 → 相同文本

### 3. **容错能力**
- 优雅处理不完整或格式错误的输入
- 为预期但缺失的元素提供缺失节点
- 为语法错误提供错误节点而不崩溃

### 4. **性能优化**
- 通过基于arena的驻留实现内容共享
- 高效的基于路径的编辑操作
- 常见操作的最小内存分配

### 5. **API清晰性**
- 为不同用例提供多种API模式
- 创建、转换和分析的清晰分离
- 具有全面错误处理的类型安全操作

## 📜 许可证

本项目采用Apache-2.0许可证。详情请见LICENSE文件。

## 📢 联系与支持

• MoonBit社区: [moonbit-community](https://github.com/moonbitlang/moonbit-community)  
• GitHub Issues: [报告问题](https://github.com/0Ayachi0/lossless_syntax_trees/issues)  

## 📝 更新日志

### v0.1.0
- ✅ 实现完整的无损语法树框架
- ✅ 支持trivia的全保真文本重建
- ✅ 全面的API设计：Make、With和Builder模式
- ✅ 高级的基于路径的编辑和结构修改
- ✅ 健壮的错误处理和容错机制
- ✅ 内存高效的基于arena的内容共享系统
- ✅ 广泛的搜索和遍历功能
- ✅ 具有结构共享的不可变转换
- ✅ 包含48个测试和90%+覆盖率的全面测试套件
- ✅ 完整的文档和使用示例

## 🔍 技术背景

### 无损语法树
无损语法树保留原始源代码的所有信息：
- **语义信息**: 变量、函数、表达式、语句
- **语法信息**: 操作符、关键字、分隔符、结构
- **词法信息**: 空白字符、注释、格式、换行符

### Trivia所有权规则
- token拥有紧随其后直到下一个换行符的所有trivia
- token拥有紧接其前包含换行符的所有trivia
- 这确保了在树修改期间正确的trivia归属

### 应用场景
此框架作为以下工具的基础：
- **代码格式化器**: 保留用户格式化偏好
- **重构工具**: 在转换期间维护代码结构
- **IDE功能**: 语法高亮、自动完成、错误报告
- **静态分析**: 代码质量工具和linter
- **代码生成**: 基于模板的代码生成与格式化

## 📚 参考资料

- [Swift lib/Syntax设计文档](https://github.com/apple/swift/tree/main/docs/Syntax.md)
- [Rust Analyzer Rowan](https://github.com/rust-analyzer/rowan)
- [Roslyn (.NET编译器平台) 语法树](https://docs.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/syntax-tree-structure)
- [Tree-sitter增量解析](https://tree-sitter.github.io/tree-sitter/)

👋 如果您喜欢这个项目，请给它一个⭐！祝您使用无损语法树编程愉快！🚀 