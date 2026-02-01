"""Tests for navigation functions (get_children, get_document_element, etc.)"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:xml.bzl", "xml")

def _get_document_element_test_impl(ctx):
    """Test get_document_element function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    asserts.true(env, root != None, "Should return root element")
    asserts.equals(env, "root", xml.get_tag_name(root))

    return unittest.end(env)

_get_document_element_test = unittest.make(_get_document_element_test_impl)

def _get_document_element_with_prolog_test_impl(ctx):
    """Test get_document_element skips XML declaration and comments."""
    env = unittest.begin(ctx)

    doc = xml.parse('<?xml version="1.0"?><!-- comment --><root/>')
    root = xml.get_document_element(doc)

    asserts.true(env, root != None, "Should return root element")
    asserts.equals(env, "root", xml.get_tag_name(root))

    return unittest.end(env)

_get_document_element_with_prolog_test = unittest.make(_get_document_element_with_prolog_test_impl)

def _get_document_element_on_non_document_test_impl(ctx):
    """Test get_document_element returns None for non-documents."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    # Calling on an element should return None
    result = xml.get_document_element(root)
    asserts.equals(env, None, result)

    return unittest.end(env)

_get_document_element_on_non_document_test = unittest.make(_get_document_element_on_non_document_test_impl)

def _get_children_test_impl(ctx):
    """Test get_children function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/><c/></root>")
    root = xml.get_document_element(doc)

    children = xml.get_children(root)
    asserts.equals(env, 3, len(children))

    return unittest.end(env)

_get_children_test = unittest.make(_get_children_test_impl)

def _get_children_includes_text_test_impl(ctx):
    """Test get_children includes text nodes."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>text<child/>more</root>")
    root = xml.get_document_element(doc)

    children = xml.get_children(root)
    asserts.true(env, len(children) >= 3, "Should include text and element nodes")

    return unittest.end(env)

_get_children_includes_text_test = unittest.make(_get_children_includes_text_test_impl)

def _get_children_empty_test_impl(ctx):
    """Test get_children with no children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    children = xml.get_children(root)
    asserts.equals(env, 0, len(children))

    return unittest.end(env)

_get_children_empty_test = unittest.make(_get_children_empty_test_impl)

def _get_children_on_document_test_impl(ctx):
    """Test get_children works on document node."""
    env = unittest.begin(ctx)

    doc = xml.parse("<!-- comment --><root/>")
    children = xml.get_children(doc)

    asserts.true(env, len(children) >= 1, "Document should have children")

    return unittest.end(env)

_get_children_on_document_test = unittest.make(_get_children_on_document_test_impl)

def _get_child_elements_test_impl(ctx):
    """Test get_child_elements function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>text<a/>more<b/>end<c/></root>")
    root = xml.get_document_element(doc)

    elements = xml.get_child_elements(root)
    asserts.equals(env, 3, len(elements))
    asserts.equals(env, "a", xml.get_tag_name(elements[0]))
    asserts.equals(env, "b", xml.get_tag_name(elements[1]))
    asserts.equals(env, "c", xml.get_tag_name(elements[2]))

    return unittest.end(env)

_get_child_elements_test = unittest.make(_get_child_elements_test_impl)

def _get_child_elements_empty_test_impl(ctx):
    """Test get_child_elements with only text children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>only text</root>")
    root = xml.get_document_element(doc)

    elements = xml.get_child_elements(root)
    asserts.equals(env, 0, len(elements))

    return unittest.end(env)

_get_child_elements_empty_test = unittest.make(_get_child_elements_empty_test_impl)

def _get_first_child_test_impl(ctx):
    """Test get_first_child function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/><c/></root>")
    root = xml.get_document_element(doc)

    first = xml.get_first_child(root)
    asserts.true(env, first != None, "Should have first child")
    asserts.equals(env, "a", xml.get_tag_name(first))

    return unittest.end(env)

_get_first_child_test = unittest.make(_get_first_child_test_impl)

def _get_first_child_empty_test_impl(ctx):
    """Test get_first_child with no children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    first = xml.get_first_child(root)
    asserts.equals(env, None, first)

    return unittest.end(env)

_get_first_child_empty_test = unittest.make(_get_first_child_empty_test_impl)

def _get_last_child_test_impl(ctx):
    """Test get_last_child function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/><c/></root>")
    root = xml.get_document_element(doc)

    last = xml.get_last_child(root)
    asserts.true(env, last != None, "Should have last child")
    asserts.equals(env, "c", xml.get_tag_name(last))

    return unittest.end(env)

_get_last_child_test = unittest.make(_get_last_child_test_impl)

def _get_last_child_empty_test_impl(ctx):
    """Test get_last_child with no children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    last = xml.get_last_child(root)
    asserts.equals(env, None, last)

    return unittest.end(env)

_get_last_child_empty_test = unittest.make(_get_last_child_empty_test_impl)

def _get_first_child_element_test_impl(ctx):
    """Test get_first_child_element function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>text<a/><b/></root>")
    root = xml.get_document_element(doc)

    first = xml.get_first_child_element(root)
    asserts.true(env, first != None, "Should have first element child")
    asserts.equals(env, "a", xml.get_tag_name(first))

    return unittest.end(env)

_get_first_child_element_test = unittest.make(_get_first_child_element_test_impl)

def _get_first_child_element_empty_test_impl(ctx):
    """Test get_first_child_element with no element children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>only text</root>")
    root = xml.get_document_element(doc)

    first = xml.get_first_child_element(root)
    asserts.equals(env, None, first)

    return unittest.end(env)

_get_first_child_element_empty_test = unittest.make(_get_first_child_element_empty_test_impl)

def _get_last_child_element_test_impl(ctx):
    """Test get_last_child_element function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/>text</root>")
    root = xml.get_document_element(doc)

    last = xml.get_last_child_element(root)
    asserts.true(env, last != None, "Should have last element child")
    asserts.equals(env, "b", xml.get_tag_name(last))

    return unittest.end(env)

_get_last_child_element_test = unittest.make(_get_last_child_element_test_impl)

def _get_last_child_element_empty_test_impl(ctx):
    """Test get_last_child_element with no element children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>only text</root>")
    root = xml.get_document_element(doc)

    last = xml.get_last_child_element(root)
    asserts.equals(env, None, last)

    return unittest.end(env)

_get_last_child_element_empty_test = unittest.make(_get_last_child_element_empty_test_impl)

def _count_children_test_impl(ctx):
    """Test count_children function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/><c/></root>")
    root = xml.get_document_element(doc)

    asserts.equals(env, 3, xml.count_children(root))

    return unittest.end(env)

_count_children_test = unittest.make(_count_children_test_impl)

def _count_children_with_text_test_impl(ctx):
    """Test count_children includes text nodes."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>text<child/>more</root>")
    root = xml.get_document_element(doc)

    count = xml.count_children(root)
    asserts.true(env, count >= 3, "Should count text and element nodes")

    return unittest.end(env)

_count_children_with_text_test = unittest.make(_count_children_with_text_test_impl)

def _count_child_elements_test_impl(ctx):
    """Test count_child_elements function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>text<a/>more<b/>end<c/></root>")
    root = xml.get_document_element(doc)

    asserts.equals(env, 3, xml.count_child_elements(root))

    return unittest.end(env)

_count_child_elements_test = unittest.make(_count_child_elements_test_impl)

def _walk_test_impl(ctx):
    """Test walk function visits all nodes."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b><c/></b></root>")
    root = xml.get_document_element(doc)

    # Collect all visited node tag names
    visited = []

    def collect_tags(node):
        if xml.is_element(node):
            visited.append(xml.get_tag_name(node))

    xml.walk(root, collect_tags)

    # Should visit root, a, b, c
    asserts.equals(env, 4, len(visited))
    asserts.true(env, "root" in visited, "Should visit root")
    asserts.true(env, "a" in visited, "Should visit a")
    asserts.true(env, "b" in visited, "Should visit b")
    asserts.true(env, "c" in visited, "Should visit c")

    return unittest.end(env)

_walk_test = unittest.make(_walk_test_impl)

def _walk_with_text_test_impl(ctx):
    """Test walk visits text nodes."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello<child>World</child></root>")
    root = xml.get_document_element(doc)

    text_count = [0]  # Use list to allow mutation in closure

    def count_text(node):
        if xml.is_text(node):
            text_count[0] += 1

    xml.walk(root, count_text)

    asserts.true(env, text_count[0] >= 2, "Should visit text nodes")

    return unittest.end(env)

_walk_with_text_test = unittest.make(_walk_with_text_test_impl)

def _walk_empty_element_test_impl(ctx):
    """Test walk on empty element."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    count = [0]

    def counter(_node):
        count[0] += 1

    xml.walk(root, counter)

    asserts.equals(env, 1, count[0])  # Just the root

    return unittest.end(env)

_walk_empty_element_test = unittest.make(_walk_empty_element_test_impl)

def _walk_deeply_nested_test_impl(ctx):
    """Test walk traverses deeply nested structures."""
    env = unittest.begin(ctx)

    doc = xml.parse("<a><b><c><d><e/></d></c></b></a>")
    root = xml.get_document_element(doc)

    visited = []

    def collect(node):
        if xml.is_element(node):
            visited.append(xml.get_tag_name(node))

    xml.walk(root, collect)

    asserts.equals(env, 5, len(visited))
    asserts.equals(env, "a", visited[0])  # First visited
    asserts.equals(env, "e", visited[4])  # Last visited (deepest)

    return unittest.end(env)

_walk_deeply_nested_test = unittest.make(_walk_deeply_nested_test_impl)

def _get_parent_test_impl(ctx):
    """Test get_parent returns the parent element."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child><grandchild/></child></root>")
    root = xml.get_document_element(doc)
    child = xml.get_first_child_element(root)
    grandchild = xml.get_first_child_element(child)

    # Test parent of grandchild is child
    parent = xml.get_parent(grandchild)
    asserts.true(env, parent != None, "grandchild should have a parent")
    asserts.equals(env, "child", xml.get_tag_name(parent))

    # Test parent of child is root
    parent2 = xml.get_parent(child)
    asserts.true(env, parent2 != None, "child should have a parent")
    asserts.equals(env, "root", xml.get_tag_name(parent2))

    return unittest.end(env)

_get_parent_test = unittest.make(_get_parent_test_impl)

def _get_parent_of_root_test_impl(ctx):
    """Test get_parent of root element returns None."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    # Root element has no parent (None)
    parent = xml.get_parent(root)
    asserts.true(env, parent == None, "root element should have no parent")

    return unittest.end(env)

_get_parent_of_root_test = unittest.make(_get_parent_of_root_test_impl)

def _get_parent_of_text_node_test_impl(ctx):
    """Test get_parent works on text nodes."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>text content</root>")
    root = xml.get_document_element(doc)
    children = xml.get_children(root)

    # Find the text node
    text_node = None
    for child in children:
        if xml.is_text(child):
            text_node = child
            break

    asserts.true(env, text_node != None, "Should find text node")

    # Parent of text node should be root
    parent = xml.get_parent(text_node)
    asserts.true(env, parent != None, "text node should have a parent")
    asserts.equals(env, "root", xml.get_tag_name(parent))

    return unittest.end(env)

_get_parent_of_text_node_test = unittest.make(_get_parent_of_text_node_test_impl)

def _get_parent_chain_test_impl(ctx):
    """Test traversing up the parent chain."""
    env = unittest.begin(ctx)

    doc = xml.parse("<a><b><c><d/></c></b></a>")
    d_elem = xml.find_element_by_tag_name(doc, "d")

    # Walk up the parent chain: d -> c -> b -> a -> None
    asserts.true(env, d_elem != None, "Should find d element")

    c_elem = xml.get_parent(d_elem)
    asserts.true(env, c_elem != None, "d should have parent")
    asserts.equals(env, "c", xml.get_tag_name(c_elem))

    b_elem = xml.get_parent(c_elem)
    asserts.true(env, b_elem != None, "c should have parent")
    asserts.equals(env, "b", xml.get_tag_name(b_elem))

    a_elem = xml.get_parent(b_elem)
    asserts.true(env, a_elem != None, "b should have parent")
    asserts.equals(env, "a", xml.get_tag_name(a_elem))

    # a is root, so its parent should be None
    no_parent = xml.get_parent(a_elem)
    asserts.true(env, no_parent == None, "a (root) should have no parent")

    return unittest.end(env)

_get_parent_chain_test = unittest.make(_get_parent_chain_test_impl)

def navigation_test_suite(name):
    """Test suite for navigation functions."""
    unittest.suite(
        name,
        _get_document_element_test,
        _get_document_element_with_prolog_test,
        _get_document_element_on_non_document_test,
        _get_children_test,
        _get_children_includes_text_test,
        _get_children_empty_test,
        _get_children_on_document_test,
        _get_child_elements_test,
        _get_child_elements_empty_test,
        _get_first_child_test,
        _get_first_child_empty_test,
        _get_last_child_test,
        _get_last_child_empty_test,
        _get_first_child_element_test,
        _get_first_child_element_empty_test,
        _get_last_child_element_test,
        _get_last_child_element_empty_test,
        _count_children_test,
        _count_children_with_text_test,
        _count_child_elements_test,
        _walk_test,
        _walk_with_text_test,
        _walk_empty_element_test,
        _walk_deeply_nested_test,
        _get_parent_test,
        _get_parent_of_root_test,
        _get_parent_of_text_node_test,
        _get_parent_chain_test,
    )
