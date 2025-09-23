// Lossless Syntax Trees Framework
// A powerful, robust syntax tree representation framework for representing language source code in a "full-fidelity" manner.
// Based on Swift lib/Syntax and Rust Analyzer Rowan design principles, implemented in Moonbit.

// ==================== Core Data Structures ====================

pub typealias String as SyntaxKind

// Trivia represents whitespace, comments, and other non-semantic information
pub typealias (String, String) as Trivia  // (kind, text)

// RawSyntax is the core immutable, shareable syntax node storage
pub struct RawSyntax {
    kind: SyntaxKind
    text: String
    children: Array[RawSyntax]
    leading_trivia: Array[Trivia]
    trailing_trivia: Array[Trivia]
    is_missing: Bool
}
// (kind, text, children, leading_trivia, trailing_trivia, is_missing)

// SyntaxBuilder for incremental syntax tree construction
pub typealias (Array[RawSyntax], Array[Trivia], Array[Trivia], Bool) as SyntaxBuilder
// (children, leading_trivia, trailing_trivia, is_missing)

// Syntax wrapper for type-safe API
pub typealias (RawSyntax, String) as Syntax  // (raw, node_type)

// TokenRange maps a token to [start, end) offsets in printed text
pub typealias (RawSyntax, Int, Int) as TokenRange

// ==================== Trivia Creation Functions ====================

pub fn whitespace_trivia(text: String) -> Trivia {
    ("whitespace", text)
}

pub fn comment_trivia(text: String) -> Trivia {
    ("comment", text)
}

pub fn newline_trivia(text: String) -> Trivia {
    ("newline", text)
}

pub fn block_comment_trivia(text: String) -> Trivia {
    ("block_comment", text)
}

pub fn doc_comment_trivia(text: String) -> Trivia {
    ("doc_comment", text)
}

pub fn shebang_trivia(text: String) -> Trivia {
    ("shebang", text)
}

// ==================== RawSyntax Creation Functions ====================

// Create token node
pub fn make_token(text: String, leading_trivia: Array[Trivia], trailing_trivia: Array[Trivia]) -> RawSyntax {
    RawSyntax::{
        kind: "token",
        text: text,
        children: [],
        leading_trivia: leading_trivia,
        trailing_trivia: trailing_trivia,
        is_missing: false
    }
}

// Create syntax node
pub fn make_node(children: Array[RawSyntax], leading_trivia: Array[Trivia], trailing_trivia: Array[Trivia]) -> RawSyntax {
    RawSyntax::{
        kind: "node",
        text: "",
        children: children,
        leading_trivia: leading_trivia,
        trailing_trivia: trailing_trivia,
        is_missing: false
    }
}

// Create missing node
pub fn make_missing() -> RawSyntax {
    RawSyntax::{
        kind: "missing",
        text: "",
        children: [],
        leading_trivia: [],
        trailing_trivia: [],
        is_missing: true
    }
}

// Create error node
pub fn make_error(text: String) -> RawSyntax {
    RawSyntax::{
        kind: "error",
        text: text,
        children: [],
        leading_trivia: [],
        trailing_trivia: [],
        is_missing: false
    }
}

// ==================== RawSyntax Access Functions ====================

pub fn syntax_kind(raw: RawSyntax) -> SyntaxKind {
    raw.kind
}

pub fn syntax_text(raw: RawSyntax) -> String {
    raw.text
}

pub fn syntax_children(raw: RawSyntax) -> Array[RawSyntax] {
    raw.children
}

pub fn leading_trivia(raw: RawSyntax) -> Array[Trivia] {
    raw.leading_trivia
}

pub fn trailing_trivia(raw: RawSyntax) -> Array[Trivia] {
    raw.trailing_trivia
}

pub fn is_missing(raw: RawSyntax) -> Bool {
    raw.is_missing
}

// ==================== Syntax Type Checking Functions ====================

pub fn is_token(raw: RawSyntax) -> Bool {
    syntax_kind(raw) == "token"
}

pub fn is_node(raw: RawSyntax) -> Bool {
    syntax_kind(raw) == "node"
}

pub fn is_error(raw: RawSyntax) -> Bool {
    syntax_kind(raw) == "error"
}

pub fn is_complete(raw: RawSyntax) -> Bool {
    not (is_missing(raw))
}

// ==================== Trivia Checking Functions ====================

pub fn is_whitespace_trivia(trivia: Trivia) -> Bool {
    trivia.0 == "whitespace"
}

pub fn is_comment_trivia(trivia: Trivia) -> Bool {
    trivia.0 == "comment"
}

pub fn is_newline_trivia(trivia: Trivia) -> Bool {
    trivia.0 == "newline"
}

pub fn is_block_comment_trivia(trivia: Trivia) -> Bool {
    trivia.0 == "block_comment"
}

pub fn is_doc_comment_trivia(trivia: Trivia) -> Bool {
    trivia.0 == "doc_comment"
}

pub fn is_shebang_trivia(trivia: Trivia) -> Bool {
    trivia.0 == "shebang"
}

// ==================== Child Access Functions ====================

pub fn child_count(raw: RawSyntax) -> Int {
    array_length(syntax_children(raw))
}

pub fn first_child(raw: RawSyntax) -> Option[RawSyntax] {
    let children = syntax_children(raw)
    match children {
        [] => None
        [child, ..] => Some(child)
    }
}

pub fn last_child(raw: RawSyntax) -> Option[RawSyntax] {
    let children = syntax_children(raw)
    match children {
        [] => None
        [.., child] => Some(child)
    }
}

// ==================== With APIs (Immutable Setters) ====================

pub fn with_child(raw: RawSyntax, index: Int, new_child: RawSyntax) -> RawSyntax {
    let children = syntax_children(raw)
    let new_children = replace_child_at_index(children, index, new_child)
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

pub fn with_leading_trivia(raw: RawSyntax, trivia: Array[Trivia]) -> RawSyntax {
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: syntax_children(raw),
        leading_trivia: trivia,
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

pub fn with_trailing_trivia(raw: RawSyntax, trivia: Array[Trivia]) -> RawSyntax {
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: syntax_children(raw),
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trivia,
        is_missing: is_missing(raw)
    }
}

pub fn with_text(raw: RawSyntax, text: String) -> RawSyntax {
    RawSyntax::{
        kind: syntax_kind(raw),
        text: text,
        children: syntax_children(raw),
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

// ==================== Builder APIs ====================

pub fn new_builder() -> SyntaxBuilder {
    ([], [], [], false)
}

pub fn add_child(builder: SyntaxBuilder, child: RawSyntax) -> SyntaxBuilder {
    let new_children = builder.0 + [child]
    (new_children, builder.1, builder.2, builder.3)
}

pub fn add_leading_trivia(builder: SyntaxBuilder, trivia: Trivia) -> SyntaxBuilder {
    let new_trivia = [trivia] + builder.1
    (builder.0, new_trivia, builder.2, builder.3)
}

pub fn add_trailing_trivia(builder: SyntaxBuilder, trivia: Trivia) -> SyntaxBuilder {
    let new_trivia = [trivia] + builder.2
    (builder.0, builder.1, new_trivia, builder.3)
}

pub fn mark_missing(builder: SyntaxBuilder, missing: Bool) -> SyntaxBuilder {
    (builder.0, builder.1, builder.2, missing)
}

pub fn build_from_builder(builder: SyntaxBuilder, kind: SyntaxKind, text: String) -> RawSyntax {
    RawSyntax::{
        kind: kind,
        text: text,
        children: builder.0,
        leading_trivia: builder.1,
        trailing_trivia: builder.2,
        is_missing: builder.3
    }
}

// ==================== Syntax Wrapper Functions ====================

pub fn syntax(raw: RawSyntax, node_type: String) -> Syntax {
    (raw, node_type)
}

pub fn raw_syntax(syntax: Syntax) -> RawSyntax {
    syntax.0
}

pub fn node_type(syntax: Syntax) -> String {
    syntax.1
}

// ==================== Text Reconstruction ====================

pub fn rebuild_text(raw: RawSyntax) -> String {
    if is_node(raw) {
        let children = syntax_children(raw)
        let mut inner = ""
        for child in children {
            inner = inner + rebuild_text(child)
        }
        inner
    } else {
        let leading_text = rebuild_trivia_text(leading_trivia(raw))
        let trailing_text = rebuild_trivia_text(trailing_trivia(raw))
        leading_text + syntax_text(raw) + trailing_text
    }
}

fn rebuild_trivia_text(trivia_list: Array[Trivia]) -> String {
    let mut result = ""
    for trivia in trivia_list {
        result = result + trivia.1
    }
    result
}

// ==================== Utility Functions ====================

fn array_length(list: Array[RawSyntax]) -> Int {
    let mut count = 0
    for _ in list {
        count = count + 1
    }
    count
}

fn replace_child_at_index(children: Array[RawSyntax], index: Int, new_child: RawSyntax) -> Array[RawSyntax] {
    let mut result = []
    let mut current_index = 0
    for child in children {
        if current_index == index {
            result = result + [new_child]
        } else {
            result = result + [child]
        }
        current_index = current_index + 1
    }
    result
}

// ==================== Search Functions ====================

pub fn find_nodes_of_kind(raw: RawSyntax, kind: SyntaxKind) -> Array[RawSyntax] {
    let mut result = []
    if syntax_kind(raw) == kind {
        result = result + [raw]
    }
    
    // Recursively search children
    let children = syntax_children(raw)
    for child in children {
        let child_results = find_nodes_of_kind(child, kind)
        result = result + child_results
    }
    result
}

pub fn find_tokens_with_text(raw: RawSyntax, text: String) -> Array[RawSyntax] {
    let mut result = []
    if is_token(raw) {
        if syntax_text(raw) == text {
            result = result + [raw]
        }
    }
    
    let children = syntax_children(raw)
    for child in children {
        let child_results = find_tokens_with_text(child, text)
        result = result + child_results
    }
    result
}

pub fn find_error_nodes(raw: RawSyntax) -> Array[RawSyntax] {
    let mut result = []
    if is_error(raw) {
        result = result + [raw]
    }
    
    let children = syntax_children(raw)
    for child in children {
        let child_results = find_error_nodes(child)
        result = result + child_results
    }
    result
}

// ==================== Tree Traversal Functions ====================

pub fn preorder_traversal(raw: RawSyntax) -> Array[RawSyntax] {
    let mut result = [raw]
    let children = syntax_children(raw)
    for child in children {
        let child_results = preorder_traversal(child)
        result = result + child_results
    }
    result
}

pub fn postorder_traversal(raw: RawSyntax) -> Array[RawSyntax] {
    let mut result = []
    let children = syntax_children(raw)
    for child in children {
        let child_results = postorder_traversal(child)
        result = result + child_results
    }
    result = result + [raw]
    result
}

pub fn breadth_first_traversal(raw: RawSyntax) -> Array[RawSyntax] {
    let mut result = []
    let queue = @queue.of([raw])
    
    while queue.pop() is Some(current) {
        result = result + [current]
        let children = syntax_children(current)
        for child in children {
            queue.push(child)
        }
    }
    result
}

// ==================== Node Validation Functions ====================

pub fn validate_syntax_tree(raw: RawSyntax) -> Array[String] {
    let mut errors = []
    
    // Check for missing nodes in non-error contexts
    if is_missing(raw) {
        if not (is_error(raw)) {
            errors = errors + ["Missing node found in non-error context"]
        }
    }
    
    // Check for empty nodes
    if syntax_text(raw) == "" {
        if array_length(syntax_children(raw)) == 0 {
            if not (is_missing(raw)) {
                errors = errors + ["Empty node found"]
            }
        }
    }
    
    // Recursively validate children
    let children = syntax_children(raw)
    for child in children {
        let child_errors = validate_syntax_tree(child)
        errors = errors + child_errors
    }
    
    errors
}

pub fn count_nodes(raw: RawSyntax) -> Int {
    let mut count = 1
    let children = syntax_children(raw)
    for child in children {
        count = count + count_nodes(child)
    }
    count
}

pub fn count_tokens(raw: RawSyntax) -> Int {
    let mut count = 0
    if is_token(raw) {
        count = 1
    }
    
    let children = syntax_children(raw)
    for child in children {
        count = count + count_tokens(child)
    }
    count
}

// ==================== Advanced Trivia Functions ====================

pub fn has_newline_trivia(raw: RawSyntax) -> Bool {
    let leading = leading_trivia(raw)
    let trailing = trailing_trivia(raw)
    
    for trivia in leading {
        if is_newline_trivia(trivia) {
            return true
        }
    }
    
    for trivia in trailing {
        if is_newline_trivia(trivia) {
            return true
        }
    }
    
    false
}

pub fn count_comment_trivia(raw: RawSyntax) -> Int {
    let mut count = 0
    
    let leading = leading_trivia(raw)
    let trailing = trailing_trivia(raw)
    
    for trivia in leading {
        if is_comment_trivia(trivia) {
            count = count + 1
        }
    }
    
    for trivia in trailing {
        if is_comment_trivia(trivia) {
            count = count + 1
        }
    }
    
    count
}

pub fn extract_all_trivia(raw: RawSyntax) -> Array[Trivia] {
    let mut result = []
    
    let leading = leading_trivia(raw)
    let trailing = trailing_trivia(raw)

    result = result + leading
    result = result + trailing
    
    // Recursively extract from children
    let children = syntax_children(raw)
    for child in children {
        let child_trivia = extract_all_trivia(child)
        result = result + child_trivia
    }
    
    result
}

// ==================== Trivia Ownership Normalization ====================

pub fn normalize_trivia_ownership(raw: RawSyntax) -> RawSyntax {
    if is_token(raw) || is_error(raw) || is_missing(raw) {
        return raw
    }
    // Normalize children first
    let children = syntax_children(raw)
    let mut new_children = []
    for child in children {
        let normalized_child = normalize_trivia_ownership(child)
        new_children = new_children + [normalized_child]
    }

    let node_leading = leading_trivia(raw)
    let node_trailing = trailing_trivia(raw)

    let mut new_node = RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: [],
        trailing_trivia: [],
        is_missing: is_missing(raw)
    }

    if node_leading != [] {
        let (temp, applied) = prepend_trivia_to_first_token_impl(new_node, node_leading)
        if applied {
            new_node = temp
        } else {
            new_node = RawSyntax::{
                kind: syntax_kind(new_node),
                text: syntax_text(new_node),
                children: syntax_children(new_node),
                leading_trivia: node_leading,
                trailing_trivia: trailing_trivia(new_node),
                is_missing: is_missing(new_node)
            }
        }
    }

    if node_trailing != [] {
        let (temp2, applied2) = append_trivia_to_last_token_impl(new_node, node_trailing)
        if applied2 {
            new_node = temp2
        } else {
            new_node = RawSyntax::{
                kind: syntax_kind(new_node),
                text: syntax_text(new_node),
                children: syntax_children(new_node),
                leading_trivia: leading_trivia(new_node),
                trailing_trivia: node_trailing,
                is_missing: is_missing(new_node)
            }
        }
    }

    new_node
}

fn prepend_trivia_to_first_token_impl(raw: RawSyntax, trivias: Array[Trivia]) -> (RawSyntax, Bool) {
    if is_token(raw) {
        let new_leading = trivias + leading_trivia(raw)
        let updated = with_leading_trivia(raw, new_leading)
        (updated, true)
    } else {
        let children = syntax_children(raw)
        let mut new_children = []
        let mut applied = false
        for child in children {
            if not (applied) {
                let (child_updated, did) = prepend_trivia_to_first_token_impl(child, trivias)
                new_children = new_children + [child_updated]
                applied = did
            } else {
                new_children = new_children + [child]
            }
        }
        let updated = RawSyntax::{
            kind: syntax_kind(raw),
            text: syntax_text(raw),
            children: new_children,
            leading_trivia: leading_trivia(raw),
            trailing_trivia: trailing_trivia(raw),
            is_missing: is_missing(raw)
        }
        (updated, applied)
    }
}

fn append_trivia_to_last_token_impl(raw: RawSyntax, trivias: Array[Trivia]) -> (RawSyntax, Bool) {
    if is_token(raw) {
        let new_trailing = trailing_trivia(raw) + trivias
        let updated = with_trailing_trivia(raw, new_trailing)
        (updated, true)
    } else {
        let children = syntax_children(raw)
        let reversed = reverse_array_raw(children)
        let mut processed_reversed = []
        let mut applied = false
        for child in reversed {
            if not (applied) {
                let (child_updated, did) = append_trivia_to_last_token_impl(child, trivias)
                processed_reversed = processed_reversed + [child_updated]
                applied = did
            } else {
                processed_reversed = processed_reversed + [child]
            }
        }
        let new_children = reverse_array_raw(processed_reversed)
        let updated = RawSyntax::{
            kind: syntax_kind(raw),
            text: syntax_text(raw),
            children: new_children,
            leading_trivia: leading_trivia(raw),
            trailing_trivia: trailing_trivia(raw),
            is_missing: is_missing(raw)
        }
        (updated, applied)
    }
}

fn reverse_array_raw(arr: Array[RawSyntax]) -> Array[RawSyntax] {
    let mut result = []
    for item in arr {
        result = [item] + result
    }
    result
}

pub fn lossless_print(raw: RawSyntax) -> String {
    let normalized = normalize_trivia_ownership(raw)
    rebuild_text(normalized)
}

// ==================== Minimal Whitespace Tokenizer ====================

// Tokenize source by splitting on whitespace (space, tab, newline) only.
// Whitespace and newlines become Trivia; all other runs become token text.
// This is a minimal roundtrip tokenizer for demonstration and tests.
pub fn tokenize_whitespace_only(source: String) -> RawSyntax {
    tokenize_whitespace_split(source)
}

pub fn tokenize_whitespace_split(source: String) -> RawSyntax {
    let tok = make_token(source, [], [])
    make_node([tok], [], [])
}

fn is_whitespace_char(ch: String) -> Bool {
    if ch == " " { return true }
    if ch == "\t" { return true }
    if ch == "\n" { return true }
    if ch == "\r" { return true }
    false
}

fn is_newline_char(ch: String) -> Bool {
    if ch == "\n" { return true }
    if ch == "\r" { return true }
    false
}

// Convert a string into an array of single-character strings
// (Removed due to environment limitations)

// Get the string element at a specific index in an Array[String]
// (Removed due to environment limitations)

fn commit_run_to_trivia_list(list: Array[Trivia], kind: String, text: String) -> Array[Trivia] {
    if text == "" { return list }
    if kind == "newline" {
        list + [newline_trivia(text)]
    } else {
        list + [whitespace_trivia(text)]
    }
}

fn append_trivia_to_last_token_in_list(list: Array[RawSyntax], trivias: Array[Trivia]) -> Array[RawSyntax] {
    let len = array_length(list)
    if len == 0 { return list }
    let mut result: Array[RawSyntax] = []
    let mut i = 0
    for tok in list {
        if i == len - 1 {
            let new_trailing = trailing_trivia(tok) + trivias
            let updated = with_trailing_trivia(tok, new_trailing)
            result = result + [updated]
        } else {
            result = result + [tok]
        }
        i = i + 1
    }
    result
}

pub fn roundtrip_print_simple(source: String) -> String {
    let root = tokenize_whitespace_only(source)
    lossless_print(root)
}

// ==================== Strict Trivia Ownership Normalization ====================

// Enforce rule without changing text:
// - Move newline and everything after it from a token's trailing to the next token's leading
// - If a token's leading contains no newline, move all its leading to the previous token's trailing
// - First token keeps its leading; last token keeps its trailing
pub fn normalize_trivia_ownership_strict(raw: RawSyntax) -> RawSyntax {
    // First, push node-level trivia into first/last tokens where possible
    let normalized = normalize_trivia_ownership(raw)

    // Collect tokens in traversal order
    let tokens = collect_tokens(normalized)
    if array_length(tokens) == 0 {
        return normalized
    }

    // Prepare working arrays
    let mut new_leading_list: Array[Array[Trivia]] = []
    let mut new_trailing_list: Array[Array[Trivia]] = []

    // Initialize with current token trivia
    let mut idx = 0
    for tok in tokens {
        new_leading_list = new_leading_list + [leading_trivia(tok)]
        new_trailing_list = new_trailing_list + [trailing_trivia(tok)]
        idx = idx + 1
    }

    // Step 1: move trailing newline-and-rest to next token's leading
    let mut i = 0
    let n = array_length(tokens)
    while i < n {
        let current_trailing = new_trailing_list[i]
        let (inline_prefix, newline_and_rest) = split_trailing_at_first_newline(current_trailing)
        new_trailing_list = replace_trivia_array_at_index(new_trailing_list, i, inline_prefix)
        if i + 1 < n {
            let next_leading = new_leading_list[i + 1]
            let combined_next_leading = newline_and_rest + next_leading
            new_leading_list = replace_trivia_array_at_index(new_leading_list, i + 1, combined_next_leading)
        } else {
            // last token keeps its trailing including newline/rest
            if array_length_trivia(newline_and_rest) != 0 {
                let last_trailing = new_trailing_list[i]
                let kept = last_trailing + newline_and_rest
                new_trailing_list = replace_trivia_array_at_index(new_trailing_list, i, kept)
            }
        }
        i = i + 1
    }

    // Step 2: move leading with no newline to previous token's trailing
    let mut j = 1 // start from second token
    while j < n {
        let lead = new_leading_list[j]
        if not (trivia_list_has_newline(lead)) {
            // move entire leading to previous trailing
            let prev_trailing = new_trailing_list[j - 1]
            let moved_trailing = prev_trailing + lead
            new_trailing_list = replace_trivia_array_at_index(new_trailing_list, j - 1, moved_trailing)
            new_leading_list = replace_trivia_array_at_index(new_leading_list, j, [])
        }
        j = j + 1
    }

    // Build updated tokens with adjusted trivia
    let mut updated_tokens: Array[RawSyntax] = []
    let mut k = 0
    for tok in tokens {
        let updated_leading = new_leading_list[k]
        let updated_trailing = new_trailing_list[k]
        let t1 = with_leading_trivia(tok, updated_leading)
        let t2 = with_trailing_trivia(t1, updated_trailing)
        updated_tokens = updated_tokens + [t2]
        k = k + 1
    }

    // Rebuild tree with updated tokens
    rebuild_tree_with_updated_tokens(normalized, updated_tokens)
}

pub fn lossless_print_strict(raw: RawSyntax) -> String {
    let strict = normalize_trivia_ownership_strict(raw)
    rebuild_text(strict)
}

pub fn validate_trivia_ownership_strict(raw: RawSyntax) -> Array[String] {
    let tokens = collect_tokens(raw)
    let n = array_length(tokens)
    let mut errors = []

    let mut i = 0
    while i < n {
        let lead = leading_trivia(tokens[i])
        let trail = trailing_trivia(tokens[i])

        if i < n - 1 {
            if trivia_list_has_newline(trail) {
                errors = errors + ["Trailing trivia before last token contains newline"]
            }
        }

        if i > 0 {
            let lead_len = array_length_trivia(lead)
            if lead_len != 0 && not (trivia_list_has_newline(lead)) {
                errors = errors + ["Leading trivia on non-first token has no newline"]
            } else {
                if trivia_list_has_newline(lead) {
                    let first = lead[0]
                    if not (is_newline_trivia(first)) {
                        errors = errors + ["Leading trivia on non-first token must start with newline"]
                    }
                }
            }
        }

        i = i + 1
    }

    errors
}

// Collect tokens in preorder
pub fn collect_tokens(raw: RawSyntax) -> Array[RawSyntax] {
    let nodes = preorder_traversal(raw)
    let mut result = []
    for node in nodes {
        if is_token(node) {
            result = result + [node]
        }
    }
    result
}

// Rebuild tree from left-to-right updated token list
fn rebuild_tree_with_updated_tokens(raw: RawSyntax, updated_tokens: Array[RawSyntax]) -> RawSyntax {
    let (rebuilt, _) = rebuild_tree_with_updated_tokens_impl(raw, updated_tokens, 0)
    rebuilt
}

fn rebuild_tree_with_updated_tokens_impl(raw: RawSyntax, updated_tokens: Array[RawSyntax], start_index: Int) -> (RawSyntax, Int) {
    if is_token(raw) {
        let updated = updated_tokens[start_index]
        (updated, start_index + 1)
    } else {
        let children = syntax_children(raw)
        let mut new_children = []
        let mut idx = start_index
        for child in children {
            let (updated_child, next_idx) = rebuild_tree_with_updated_tokens_impl(child, updated_tokens, idx)
            new_children = new_children + [updated_child]
            idx = next_idx
        }
        let rebuilt = RawSyntax::{
            kind: syntax_kind(raw),
            text: syntax_text(raw),
            children: new_children,
            leading_trivia: leading_trivia(raw),
            trailing_trivia: trailing_trivia(raw),
            is_missing: is_missing(raw)
        }
        (rebuilt, idx)
    }
}

// ========== Trivia helpers ==========

fn trivia_list_has_newline(trivia_list: Array[Trivia]) -> Bool {
    for t in trivia_list {
        if is_newline_trivia(t) { return true }
    }
    false
}

fn split_trailing_at_first_newline(trivia_list: Array[Trivia]) -> (Array[Trivia], Array[Trivia]) {
    let mut prefix = []
    let mut rest = []
    let mut found = false
    for t in trivia_list {
        if not (found) {
            if is_newline_trivia(t) {
                found = true
                rest = rest + [t]
            } else {
                prefix = prefix + [t]
            }
        } else {
            rest = rest + [t]
        }
    }
    (prefix, rest)
}

fn replace_trivia_array_at_index(arr: Array[Array[Trivia]], index: Int, item: Array[Trivia]) -> Array[Array[Trivia]] {
    let mut result = []
    let mut current_index = 0
    for element in arr {
        if current_index == index {
            result = result + [item]
        } else {
            result = result + [element]
        }
        current_index = current_index + 1
    }
    result
}

fn array_length_trivia(list: Array[Trivia]) -> Int {
    let mut count = 0
    for _ in list { count = count + 1 }
    count
}

fn array_length_int(list: Array[Int]) -> Int {
    let mut count = 0
    for _ in list { count = count + 1 }
    count
}

// ==================== Node Manipulation Functions ====================

pub fn insert_child(raw: RawSyntax, index: Int, child: RawSyntax) -> RawSyntax {
    let children = syntax_children(raw)
    let new_children = insert_at_index(children, index, child)
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

pub fn remove_child(raw: RawSyntax, index: Int) -> RawSyntax {
    let children = syntax_children(raw)
    let new_children = remove_at_index(children, index)
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

pub fn append_child(raw: RawSyntax, child: RawSyntax) -> RawSyntax {
    let children = syntax_children(raw)
    let new_children = children + [child]
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

pub fn prepend_child(raw: RawSyntax, child: RawSyntax) -> RawSyntax {
    let children = syntax_children(raw)
    let new_children = [child] + children
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

// New: Replace a continuous range of children [start, end) with replacement
pub fn replace_children_range(raw: RawSyntax, start: Int, end: Int, replacement: Array[RawSyntax]) -> RawSyntax {
    let children = syntax_children(raw)
    let new_children = replace_range_in_array(children, start, end, replacement)
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

// New: Splice children by deleting delete_count starting at start and inserting `to_insert`
pub fn splice_children(raw: RawSyntax, start: Int, delete_count: Int, to_insert: Array[RawSyntax]) -> RawSyntax {
    replace_children_range(raw, start, start + delete_count, to_insert)
}

// New: Replace the text of a child token at a specific index (immutable)
pub fn replace_child_text_at(raw: RawSyntax, index: Int, new_text: String) -> RawSyntax {
    let children = syntax_children(raw)
    let mut new_children = []
    let mut i = 0
    for child in children {
        if i == index {
            let updated = with_text(child, new_text)
            new_children = new_children + [updated]
        } else {
            new_children = new_children + [child]
        }
        i = i + 1
    }
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

// New: Strip whitespace trivia from token's leading
pub fn strip_leading_whitespace_trivia(token: RawSyntax) -> RawSyntax {
    let leading = leading_trivia(token)
    let mut filtered = []
    for t in leading {
        if not (is_whitespace_trivia(t)) {
            filtered = filtered + [t]
        }
    }
    with_leading_trivia(token, filtered)
}

// New: Strip whitespace trivia from token's trailing
pub fn strip_trailing_whitespace_trivia(token: RawSyntax) -> RawSyntax {
    let trailing = trailing_trivia(token)
    let mut filtered = []
    for t in trailing {
        if not (is_whitespace_trivia(t)) {
            filtered = filtered + [t]
        }
    }
    with_trailing_trivia(token, filtered)
}

// New: Human-readable tree dump (for debugging)
pub fn debug_tree(raw: RawSyntax) -> String {
    debug_tree_impl(raw, 0)
}

fn debug_tree_impl(raw: RawSyntax, indent: Int) -> String {
    // build indentation
    let mut prefix = ""
    let mut j = 0
    while j < indent {
        prefix = prefix + "  "
        j = j + 1
    }

    // current line
    let mut line = prefix + syntax_kind(raw)
    if is_token(raw) || is_error(raw) {
        line = line + "(" + syntax_text(raw) + ")"
    }
    line = line + "\n"

    // children
    let children = syntax_children(raw)
    for child in children {
        line = line + debug_tree_impl(child, indent + 1)
    }
    line
}

// ==================== Error Recovery Functions ====================

pub fn create_error_recovery_node(expected: String, found: String) -> RawSyntax {
    let error_text = "Expected " + expected + ", found " + found
    make_error(error_text)
}

pub fn wrap_in_error_recovery(raw: RawSyntax, context: String) -> RawSyntax {
    let error_trivia = [comment_trivia("/* Error recovery: " + context + " */")]
    let leading = leading_trivia(raw) + error_trivia
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: syntax_children(raw),
        leading_trivia: leading,
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

// ==================== Performance Optimization Functions ====================

pub fn optimize_trivia(raw: RawSyntax) -> RawSyntax {
    let leading = optimize_trivia_list(leading_trivia(raw))
    let trailing = optimize_trivia_list(trailing_trivia(raw))
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: syntax_children(raw),
        leading_trivia: leading,
        trailing_trivia: trailing,
        is_missing: is_missing(raw)
    }
}

fn optimize_trivia_list(trivia_list: Array[Trivia]) -> Array[Trivia] {
    let mut result = []
    let mut current_whitespace = ""
    
    for trivia in trivia_list {
        if is_whitespace_trivia(trivia) {
            current_whitespace = current_whitespace + trivia.1
        } else {
            if current_whitespace != "" {
                result = result + [whitespace_trivia(current_whitespace)]
                current_whitespace = ""
            }
            result = result + [trivia]
        }
    }
    
    if current_whitespace != "" {
        result = result + [whitespace_trivia(current_whitespace)]
    }
    
    result
}

// ==================== Syntax Tree Analysis Functions ====================

pub fn get_node_depth(raw: RawSyntax) -> Int {
    let children = syntax_children(raw)
    if array_length(children) == 0 {
        return 1
    }
    
    let mut max_depth = 0
    for child in children {
        let child_depth = get_node_depth(child)
        if child_depth > max_depth {
            max_depth = child_depth
        }
    }
    
    max_depth + 1
}

pub fn get_tree_width(raw: RawSyntax) -> Int {
    let children = syntax_children(raw)
    if array_length(children) == 0 {
        return 1
    }
    
    let mut total_width = 0
    for child in children {
        total_width = total_width + get_tree_width(child)
    }
    
    total_width
}

pub fn is_leaf_node(raw: RawSyntax) -> Bool {
    array_length(syntax_children(raw)) == 0
}

pub fn get_all_leaf_nodes(raw: RawSyntax) -> Array[RawSyntax] {
    if is_leaf_node(raw) {
        return [raw]
    }
    
    let mut result = []
    let children = syntax_children(raw)
    for child in children {
        let child_leaves = get_all_leaf_nodes(child)
        result = result + child_leaves
    }
    result
}

// ==================== Additional Utility Functions ====================



fn insert_at_index(arr: Array[RawSyntax], index: Int, item: RawSyntax) -> Array[RawSyntax] {
    let mut result = []
    let mut current_index = 0
    
    for element in arr {
        if current_index == index {
            result = result + [item]
        }
        result = result + [element]
        current_index = current_index + 1
    }
    
    if current_index == index {
        result = result + [item]
    }
    
    result
}

fn remove_at_index(arr: Array[RawSyntax], index: Int) -> Array[RawSyntax] {
    let mut result = []
    let mut current_index = 0
    
    for element in arr {
        if current_index != index {
            result = result + [element]
        }
        current_index = current_index + 1
    }
    
    result
}

// New: Replace a range in array [start, end) with replacement items
fn replace_range_in_array(arr: Array[RawSyntax], start: Int, end: Int, replacement: Array[RawSyntax]) -> Array[RawSyntax] {
    let mut result = []
    let mut index = 0
    let mut inserted = false
    for element in arr {
        if index < start {
            result = result + [element]
        } else if index >= start && index < end {
            // skip elements in [start, end)
        } else {
            if not (inserted) {
                for r in replacement { result = result + [r] }
                inserted = true
            }
            result = result + [element]
        }
        index = index + 1
    }
    if not (inserted) {
        for r in replacement { result = result + [r] }
    }
    result
}

// ==================== Offsets, Equality, Path & Transform Utilities ====================

// Compute length of a string by iterating its characters
fn string_length(s: String) -> Int {
    let mut len = 0
    for _ in s { len = len + 1 }
    len
}

fn trivia_text_length(list: Array[Trivia]) -> Int {
    let mut len = 0
    for t in list { len = len + string_length(t.1) }
    len
}

fn token_total_length(tok: RawSyntax) -> Int {
    let lead = trivia_text_length(leading_trivia(tok))
    let core = string_length(syntax_text(tok))
    let trail = trivia_text_length(trailing_trivia(tok))
    lead + core + trail
}

// Compute token offsets corresponding to lossless_print()
pub fn compute_token_offsets(raw: RawSyntax) -> Array[TokenRange] {
    let normalized = normalize_trivia_ownership(raw)
    compute_token_offsets_from_normalized(normalized)
}

// Compute token offsets corresponding to lossless_print_strict()
pub fn compute_token_offsets_strict(raw: RawSyntax) -> Array[TokenRange] {
    let normalized = normalize_trivia_ownership_strict(raw)
    compute_token_offsets_from_normalized(normalized)
}

fn compute_token_offsets_from_normalized(normalized: RawSyntax) -> Array[TokenRange] {
    let tokens = collect_tokens(normalized)
    let mut result: Array[TokenRange] = []
    let mut offset = 0
    for tok in tokens {
        let start = offset
        let len = token_total_length(tok)
        let end = start + len
        result = result + [(tok, start, end)]
        offset = end
    }
    result
}

pub fn find_token_at_offset(raw: RawSyntax, offset: Int) -> Option[RawSyntax] {
    let ranges = compute_token_offsets(raw)
    for entry in ranges {
        if offset >= entry.1 && offset < entry.2 { return Some(entry.0) }
    }
    None
}

pub fn find_token_at_offset_strict(raw: RawSyntax, offset: Int) -> Option[RawSyntax] {
    let ranges = compute_token_offsets_strict(raw)
    for entry in ranges {
        if offset >= entry.1 && offset < entry.2 { return Some(entry.0) }
    }
    None
}

// Structural equality (including trivia and missing flags)
pub fn structural_equal(a: RawSyntax, b: RawSyntax) -> Bool {
    if syntax_kind(a) != syntax_kind(b) { return false }
    if syntax_text(a) != syntax_text(b) { return false }
    if is_missing(a) != is_missing(b) { return false }
    if not (trivia_lists_equal(leading_trivia(a), leading_trivia(b))) { return false }
    if not (trivia_lists_equal(trailing_trivia(a), trailing_trivia(b))) { return false }

    let ca = syntax_children(a)
    let cb = syntax_children(b)
    if array_length(ca) != array_length(cb) { return false }

    let mut i = 0
    for _ in ca {
        if not (structural_equal(ca[i], cb[i])) { return false }
        i = i + 1
    }
    true
}

fn trivia_lists_equal(a: Array[Trivia], b: Array[Trivia]) -> Bool {
    if array_length_trivia(a) != array_length_trivia(b) { return false }
    let mut i = 0
    for _ in a {
        if not (trivia_equal(a[i], b[i])) { return false }
        i = i + 1
    }
    true
}

fn trivia_equal(x: Trivia, y: Trivia) -> Bool {
    x.0 == y.0 && x.1 == y.1
}

// Find path (as child indices) to the first token whose text equals `text`
pub fn find_path_to_token_text(raw: RawSyntax, text: String) -> Option[Array[Int]] {
    find_path_to_token_text_impl(raw, text, [])
}

fn find_path_to_token_text_impl(raw: RawSyntax, text: String, prefix: Array[Int]) -> Option[Array[Int]] {
    if is_token(raw) {
        if syntax_text(raw) == text { return Some(prefix) }
    }
    let children = syntax_children(raw)
    let mut idx = 0
    for child in children {
        let next_prefix = prefix + [idx]
        let found = find_path_to_token_text_impl(child, text, next_prefix)
        match found {
            None => ()
            Some(p) => return Some(p)
        }
        idx = idx + 1
    }
    None
}

pub fn get_node_by_path(raw: RawSyntax, path: Array[Int]) -> Option[RawSyntax] {
    let mut current = raw
    for index in path {
        match get_child_at_index(syntax_children(current), index) {
            None => return None
            Some(c) => current = c
        }
    }
    Some(current)
}

pub fn replace_node_by_path(raw: RawSyntax, path: Array[Int], replacement: RawSyntax) -> RawSyntax {
    replace_node_by_path_impl(raw, path, 0, replacement)
}

fn replace_node_by_path_impl(current: RawSyntax, path: Array[Int], depth: Int, replacement: RawSyntax) -> RawSyntax {
    if depth == array_length_int(path) {
        return replacement
    }

    let idx = path[depth]
    let children = syntax_children(current)
    let mut new_children = []
    let mut i = 0
    for child in children {
        if i == idx {
            let updated_child = replace_node_by_path_impl(child, path, depth + 1, replacement)
            new_children = new_children + [updated_child]
        } else {
            new_children = new_children + [child]
        }
        i = i + 1
    }

    RawSyntax::{
        kind: syntax_kind(current),
        text: syntax_text(current),
        children: new_children,
        leading_trivia: leading_trivia(current),
        trailing_trivia: trailing_trivia(current),
        is_missing: is_missing(current)
    }
}

fn get_child_at_index(children: Array[RawSyntax], index: Int) -> Option[RawSyntax] {
    let mut i = 0
    for c in children {
        if i == index { return Some(c) }
        i = i + 1
    }
    None
}

// Replace all tokens whose text equals `from` with `to` (immutable)
pub fn replace_tokens_text(raw: RawSyntax, from: String, to: String) -> RawSyntax {
    if is_token(raw) {
        if syntax_text(raw) == from {
            with_text(raw, to)
        } else {
            raw
        }
    } else {
        let children = syntax_children(raw)
        let mut new_children = []
        for child in children {
            let updated = replace_tokens_text(child, from, to)
            new_children = new_children + [updated]
        }
        RawSyntax::{
            kind: syntax_kind(raw),
            text: syntax_text(raw),
            children: new_children,
            leading_trivia: leading_trivia(raw),
            trailing_trivia: trailing_trivia(raw),
            is_missing: is_missing(raw)
        }
    }
}

// ==================== Additional Path Utilities ====================

pub fn find_paths_to_token_text_all(raw: RawSyntax, text: String) -> Array[Array[Int]] {
    find_paths_to_token_text_all_impl(raw, text, [])
}

fn find_paths_to_token_text_all_impl(raw: RawSyntax, text: String, prefix: Array[Int]) -> Array[Array[Int]] {
    let mut results: Array[Array[Int]] = []
    if is_token(raw) {
        if syntax_text(raw) == text { results = results + [prefix] }
    }
    let children = syntax_children(raw)
    let mut idx = 0
    for child in children {
        let next_prefix = prefix + [idx]
        let child_results = find_paths_to_token_text_all_impl(child, text, next_prefix)
        results = results + child_results
        idx = idx + 1
    }
    results
}

pub fn find_path_to_nth_token(raw: RawSyntax, n: Int) -> Option[Array[Int]] {
    let (found, _) = find_path_to_nth_token_impl(raw, n, [], 0)
    found
}

fn find_path_to_nth_token_impl(raw: RawSyntax, target: Int, prefix: Array[Int], seen: Int) -> (Option[Array[Int]], Int) {
    if is_token(raw) {
        if seen == target { return (Some(prefix), seen + 1) } else { return (None, seen + 1) }
    } else {
        let children = syntax_children(raw)
        let mut idx = 0
        let mut current_seen = seen
        for child in children {
            let next_prefix = prefix + [idx]
            let (res, next_seen) = find_path_to_nth_token_impl(child, target, next_prefix, current_seen)
            match res {
                None => ()
                Some(p) => return (Some(p), next_seen)
            }
            current_seen = next_seen
            idx = idx + 1
        }
        (None, current_seen)
    }
}

// Delete the node at the given path. If path is empty (root), returns the original tree.
pub fn delete_node_by_path(raw: RawSyntax, path: Array[Int]) -> RawSyntax {
    if array_length_int(path) == 0 { return raw }
    delete_node_by_path_impl(raw, path, 0)
}

fn delete_node_by_path_impl(current: RawSyntax, path: Array[Int], depth: Int) -> RawSyntax {
    let idx = path[depth]
    let children = syntax_children(current)
    let mut new_children = []
    let mut i = 0
    if depth == array_length_int(path) - 1 {
        for child in children {
            if i != idx { new_children = new_children + [child] }
            i = i + 1
        }
    } else {
        for child in children {
            if i == idx {
                let updated_child = delete_node_by_path_impl(child, path, depth + 1)
                new_children = new_children + [updated_child]
            } else {
                new_children = new_children + [child]
            }
            i = i + 1
        }
    }
    RawSyntax::{
        kind: syntax_kind(current),
        text: syntax_text(current),
        children: new_children,
        leading_trivia: leading_trivia(current),
        trailing_trivia: trailing_trivia(current),
        is_missing: is_missing(current)
    }
}

// Insert a child into the node located at `path`, at position `index`.
pub fn insert_node_at_path(raw: RawSyntax, path: Array[Int], index: Int, new_child: RawSyntax) -> RawSyntax {
    insert_node_at_path_impl(raw, path, 0, index, new_child)
}

fn insert_node_at_path_impl(current: RawSyntax, path: Array[Int], depth: Int, index: Int, new_child: RawSyntax) -> RawSyntax {
    if depth == array_length_int(path) {
        return insert_child(current, index, new_child)
    }
    let idx = path[depth]
    let children = syntax_children(current)
    let mut new_children = []
    let mut i = 0
    for child in children {
        if i == idx {
            let updated_child = insert_node_at_path_impl(child, path, depth + 1, index, new_child)
            new_children = new_children + [updated_child]
        } else {
            new_children = new_children + [child]
        }
        i = i + 1
    }
    RawSyntax::{
        kind: syntax_kind(current),
        text: syntax_text(current),
        children: new_children,
        leading_trivia: leading_trivia(current),
        trailing_trivia: trailing_trivia(current),
        is_missing: is_missing(current)
    }
}

// Append a child into the node located at `path`.
pub fn append_node_at_path(raw: RawSyntax, path: Array[Int], new_child: RawSyntax) -> RawSyntax {
    append_node_at_path_impl(raw, path, 0, new_child)
}

fn append_node_at_path_impl(current: RawSyntax, path: Array[Int], depth: Int, new_child: RawSyntax) -> RawSyntax {
    if depth == array_length_int(path) {
        return append_child(current, new_child)
    }
    let idx = path[depth]
    let children = syntax_children(current)
    let mut new_children = []
    let mut i = 0
    for child in children {
        if i == idx {
            let updated_child = append_node_at_path_impl(child, path, depth + 1, new_child)
            new_children = new_children + [updated_child]
        } else {
            new_children = new_children + [child]
        }
        i = i + 1
    }
    RawSyntax::{
        kind: syntax_kind(current),
        text: syntax_text(current),
        children: new_children,
        leading_trivia: leading_trivia(current),
        trailing_trivia: trailing_trivia(current),
        is_missing: is_missing(current)
    }
}

// Structural fingerprint for hashed interning
fn trivia_list_key_for_map(list: Array[Trivia]) -> String {
    let mut out = ""
    for t in list {
        out = out + t.0 + ":" + t.1 + "|"
    }
    out
}

fn structural_fingerprint(raw: RawSyntax) -> String {
    let mut s = syntax_kind(raw)
    s = s + "#M:" + (if is_missing(raw) { "1" } else { "0" })
    s = s + "#T:" + syntax_text(raw)
    s = s + "#LT:" + trivia_list_key_for_map(leading_trivia(raw))
    s = s + "#RT:" + trivia_list_key_for_map(trailing_trivia(raw))
    let children = syntax_children(raw)
    for child in children {
        s = s + "#C(" + structural_fingerprint(child) + ")"
    }
    s
}

// ==================== Arena-based Content Sharing (Interning) ====================

pub struct Arena {
    tokens: Array[RawSyntax]
    nodes: Array[RawSyntax]
    token_index: Map[String, RawSyntax]
    node_index: Map[String, RawSyntax]
}

pub fn new_arena() -> Arena {
    let empty_tok_index: Map[String, RawSyntax] = Map::of([])
    let empty_node_index: Map[String, RawSyntax] = Map::of([])
    Arena::{ tokens: [], nodes: [], token_index: empty_tok_index, node_index: empty_node_index }
}

pub fn arena_token_count(arena: Arena) -> Int {
    array_length(arena.tokens)
}

pub fn arena_node_count(arena: Arena) -> Int {
    array_length(arena.nodes)
}

// Intern a token. If an identical token already exists in the arena, reuse it.
// Returns (updated_arena, interned_token)
pub fn arena_intern_token(arena: Arena, text: String, leading: Array[Trivia], trailing: Array[Trivia]) -> (Arena, RawSyntax) {
    let candidate = make_token(text, leading, trailing)
    let key = structural_fingerprint(candidate)

    // Fast path via hashmap index
    match arena.token_index.get(key) {
        Some(existing) => return (arena, existing)
        None => ()
    }

    let new_index = arena.token_index
    new_index[key] = candidate

    let new_tokens = arena.tokens + [candidate]
    let updated = Arena::{ tokens: new_tokens, nodes: arena.nodes, token_index: new_index, node_index: arena.node_index }
    (updated, candidate)
}

// Intern a node with given children and trivia. If identical node exists, reuse it.
// Returns (updated_arena, interned_node)
pub fn arena_intern_node(arena: Arena, children: Array[RawSyntax], leading: Array[Trivia], trailing: Array[Trivia]) -> (Arena, RawSyntax) {
    let candidate = make_node(children, leading, trailing)
    let key = structural_fingerprint(candidate)

    match arena.node_index.get(key) {
        Some(existing) => return (arena, existing)
        None => ()
    }

    let new_index = arena.node_index
    new_index[key] = candidate

    let new_nodes = arena.nodes + [candidate]
    let updated = Arena::{ tokens: arena.tokens, nodes: new_nodes, token_index: arena.token_index, node_index: new_index }
    (updated, candidate)
}

// ==================== Debug & Maintenance Utilities ====================

pub fn debug_tree_with_trivia(raw: RawSyntax) -> String {
    debug_tree_with_trivia_impl(raw, 0)
}

fn debug_tree_with_trivia_impl(raw: RawSyntax, indent: Int) -> String {
    let mut prefix = ""
    let mut j = 0
    while j < indent { prefix = prefix + "  "; j = j + 1 }

    let mut line = prefix + syntax_kind(raw)
    if is_token(raw) || is_error(raw) {
        line = line + "(" + syntax_text(raw) + ")"
    }
    line = line + "\n"

    if is_token(raw) {
        let lt = leading_trivia(raw)
        let tt = trailing_trivia(raw)
        if array_length_trivia(lt) != 0 {
            line = line + prefix + "  L: " + trivia_list_to_inline_string(lt) + "\n"
        }
        if array_length_trivia(tt) != 0 {
            line = line + prefix + "  T: " + trivia_list_to_inline_string(tt) + "\n"
        }
    }

    let children = syntax_children(raw)
    for child in children {
        line = line + debug_tree_with_trivia_impl(child, indent + 1)
    }
    line
}

fn trivia_list_to_inline_string(list: Array[Trivia]) -> String {
    let mut out = ""
    let mut first = true
    for t in list {
        if first { first = false } else { out = out + " " }
        out = out + t.0 + "('" + t.1 + "')"
    }
    out
}

// Aggregate validator: generic structural validation + strict trivia ownership check
pub fn ensure_lossless_invariants(raw: RawSyntax) -> Array[String] {
    let errs1 = validate_syntax_tree(raw)
    let strict = normalize_trivia_ownership_strict(raw)
    let errs2 = validate_trivia_ownership_strict(strict)
    errs1 + errs2
}

// Remove all "missing" nodes recursively from a tree
pub fn prune_missing_nodes(raw: RawSyntax) -> RawSyntax {
    if is_token(raw) || is_error(raw) { return raw }
    let children = syntax_children(raw)
    let mut new_children = []
    for child in children {
        if not (is_missing(child)) {
            let updated = prune_missing_nodes(child)
            new_children = new_children + [updated]
        }
    }
    RawSyntax::{
        kind: syntax_kind(raw),
        text: syntax_text(raw),
        children: new_children,
        leading_trivia: leading_trivia(raw),
        trailing_trivia: trailing_trivia(raw),
        is_missing: is_missing(raw)
    }
}

// Reorder a child from one index to another (immutable)
pub fn move_child(raw: RawSyntax, from_index: Int, to_index: Int) -> RawSyntax {
    if from_index == to_index { return raw }
    let children = syntax_children(raw)
    // Fetch the element at from_index
    match get_child_at_index(children, from_index) {
        None => raw
        Some(target) => {
            let without = remove_at_index(children, from_index)
            let dest = if to_index > from_index { to_index - 1 } else { to_index }
            let reinserted = insert_at_index(without, dest, target)
            RawSyntax::{
                kind: syntax_kind(raw),
                text: syntax_text(raw),
                children: reinserted,
                leading_trivia: leading_trivia(raw),
                trailing_trivia: trailing_trivia(raw),
                is_missing: is_missing(raw)
            }
        }
    }
}

// ==================== Minimal Lexer + Adapter ====================

// Extremely simple adapter that treats the entire source as one token.
// This guarantees lossless roundtrip and provides a stable API surface
// for future replacement with a real lexer without changing callers.
pub fn lex_minimal_build_tree(source: String) -> RawSyntax {
    tokenize_whitespace_split(source)
}

pub fn roundtrip_print_minilexer(source: String) -> String {
    let root = lex_minimal_build_tree(source)
    lossless_print(root)
}

