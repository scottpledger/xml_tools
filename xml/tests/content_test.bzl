"""Tests for content functions (get_text)"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//xml:defs.bzl", "xml")

def _get_text_simple_test_impl(ctx):
    """Test get_text with simple text content."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello World</root>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "Hello World", xml.get_text(root))

    return unittest.end(env)

_get_text_simple_test = unittest.make(_get_text_simple_test_impl)

def _get_text_empty_test_impl(ctx):
    """Test get_text with empty element."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "", xml.get_text(root))

    return unittest.end(env)

_get_text_empty_test = unittest.make(_get_text_empty_test_impl)

def _get_text_nested_test_impl(ctx):
    """Test get_text concatenates text from nested elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello <b>World</b>!</root>")
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "Hello" in text, "Should contain 'Hello'")
    asserts.true(env, "World" in text, "Should contain 'World'")
    asserts.true(env, "!" in text, "Should contain '!'")

    return unittest.end(env)

_get_text_nested_test = unittest.make(_get_text_nested_test_impl)

def _get_text_deeply_nested_test_impl(ctx):
    """Test get_text with deeply nested text."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a><b><c>Deep</c></b></a></root>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "Deep", xml.get_text(root))

    return unittest.end(env)

_get_text_deeply_nested_test = unittest.make(_get_text_deeply_nested_test_impl)

def _get_text_multiple_children_test_impl(ctx):
    """Test get_text with multiple text children."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a>One</a><b>Two</b><c>Three</c></root>")
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "One" in text, "Should contain 'One'")
    asserts.true(env, "Two" in text, "Should contain 'Two'")
    asserts.true(env, "Three" in text, "Should contain 'Three'")

    return unittest.end(env)

_get_text_multiple_children_test = unittest.make(_get_text_multiple_children_test_impl)

def _get_text_from_text_node_test_impl(ctx):
    """Test get_text directly on a text node."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Text content</root>")
    root = xml.get_document_element(doc)
    children = xml.get_children(root)

    for child in children:
        if xml.is_text(child):
            asserts.equals(env, "Text content", xml.get_text(child))

    return unittest.end(env)

_get_text_from_text_node_test = unittest.make(_get_text_from_text_node_test_impl)

def _get_text_from_cdata_test_impl(ctx):
    """Test get_text includes CDATA content."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><![CDATA[CDATA content]]></root>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "CDATA content", xml.get_text(root))

    return unittest.end(env)

_get_text_from_cdata_test = unittest.make(_get_text_from_cdata_test_impl)

def _get_text_mixed_cdata_and_text_test_impl(ctx):
    """Test get_text with mixed CDATA and text."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Before<![CDATA[Middle]]>After</root>")
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "Before" in text, "Should contain 'Before'")
    asserts.true(env, "Middle" in text, "Should contain 'Middle'")
    asserts.true(env, "After" in text, "Should contain 'After'")

    return unittest.end(env)

_get_text_mixed_cdata_and_text_test = unittest.make(_get_text_mixed_cdata_and_text_test_impl)

def _get_text_with_entities_test_impl(ctx):
    """Test get_text decodes entities."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>&lt;tag&gt;</root>")
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "<" in text, "Should decode &lt;")
    asserts.true(env, ">" in text, "Should decode &gt;")

    return unittest.end(env)

_get_text_with_entities_test = unittest.make(_get_text_with_entities_test_impl)

def _get_text_preserves_whitespace_test_impl(ctx):
    """Test get_text preserves internal whitespace."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello   World</root>")
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "   " in text, "Should preserve whitespace")

    return unittest.end(env)

_get_text_preserves_whitespace_test = unittest.make(_get_text_preserves_whitespace_test_impl)

def _get_text_on_comment_test_impl(ctx):
    """Test get_text returns empty string for comment."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><!-- comment --></root>")
    root = xml.get_document_element(doc)

    for child in xml.get_children(root):
        if xml.is_comment(child):
            # Comment nodes should return empty string from get_text
            asserts.equals(env, "", xml.get_text(child))

    return unittest.end(env)

_get_text_on_comment_test = unittest.make(_get_text_on_comment_test_impl)

def _get_text_ignores_comments_test_impl(ctx):
    """Test get_text ignores comments when collecting text."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello<!-- comment -->World</root>")
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "Hello" in text, "Should contain 'Hello'")
    asserts.true(env, "World" in text, "Should contain 'World'")
    asserts.false(env, "comment" in text, "Should not contain comment text")

    return unittest.end(env)

_get_text_ignores_comments_test = unittest.make(_get_text_ignores_comments_test_impl)

def content_test_suite(name):
    """Test suite for content functions."""
    unittest.suite(
        name,
        _get_text_simple_test,
        _get_text_empty_test,
        _get_text_nested_test,
        _get_text_deeply_nested_test,
        _get_text_multiple_children_test,
        _get_text_from_text_node_test,
        _get_text_from_cdata_test,
        _get_text_mixed_cdata_and_text_test,
        _get_text_with_entities_test,
        _get_text_preserves_whitespace_test,
        _get_text_on_comment_test,
        _get_text_ignores_comments_test,
    )
