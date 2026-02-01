"""Tests for type checking functions (is_element, is_text, etc.)"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//xml:defs.bzl", "xml")

def _is_document_test_impl(ctx):
    """Test is_document function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    asserts.true(env, xml.is_document(doc), "Parsed result should be a document")

    root = xml.get_document_element(doc)
    asserts.false(env, xml.is_document(root), "Element should not be a document")

    return unittest.end(env)

_is_document_test = unittest.make(_is_document_test_impl)

def _is_element_test_impl(ctx):
    """Test is_element function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child/></root>")
    root = xml.get_document_element(doc)

    asserts.true(env, xml.is_element(root), "Root should be an element")
    asserts.false(env, xml.is_element(doc), "Document should not be an element")

    children = xml.get_child_elements(root)
    asserts.true(env, xml.is_element(children[0]), "Child should be an element")

    return unittest.end(env)

_is_element_test = unittest.make(_is_element_test_impl)

def _is_text_test_impl(ctx):
    """Test is_text function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello</root>")
    root = xml.get_document_element(doc)
    children = xml.get_children(root)

    found_text = False
    for child in children:
        if xml.is_text(child):
            found_text = True
    asserts.true(env, found_text, "Should find text node")

    asserts.false(env, xml.is_text(root), "Element should not be text")
    asserts.false(env, xml.is_text(doc), "Document should not be text")

    return unittest.end(env)

_is_text_test = unittest.make(_is_text_test_impl)

def _is_comment_test_impl(ctx):
    """Test is_comment function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><!-- comment --></root>")
    root = xml.get_document_element(doc)
    children = xml.get_children(root)

    found_comment = False
    for child in children:
        if xml.is_comment(child):
            found_comment = True
    asserts.true(env, found_comment, "Should find comment node")

    asserts.false(env, xml.is_comment(root), "Element should not be comment")

    return unittest.end(env)

_is_comment_test = unittest.make(_is_comment_test_impl)

def _is_cdata_test_impl(ctx):
    """Test is_cdata function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><![CDATA[data]]></root>")
    root = xml.get_document_element(doc)
    children = xml.get_children(root)

    found_cdata = False
    for child in children:
        if xml.is_cdata(child):
            found_cdata = True
    asserts.true(env, found_cdata, "Should find CDATA node")

    asserts.false(env, xml.is_cdata(root), "Element should not be CDATA")

    return unittest.end(env)

_is_cdata_test = unittest.make(_is_cdata_test_impl)

def _is_processing_instruction_test_impl(ctx):
    """Test is_processing_instruction function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<?target data?><root/>")
    children = doc.children

    found_pi = False
    for child in children:
        if xml.is_processing_instruction(child):
            found_pi = True
            asserts.equals(env, "target", child.target)
    asserts.true(env, found_pi, "Should find processing instruction")

    root = xml.get_document_element(doc)
    asserts.false(env, xml.is_processing_instruction(root), "Element should not be PI")

    return unittest.end(env)

_is_processing_instruction_test = unittest.make(_is_processing_instruction_test_impl)

def _type_checking_with_none_test_impl(ctx):
    """Test type checking functions handle None gracefully."""
    env = unittest.begin(ctx)

    # These should all return False for non-node values
    asserts.false(env, xml.is_element(None), "None should not be element")
    asserts.false(env, xml.is_text(None), "None should not be text")
    asserts.false(env, xml.is_comment(None), "None should not be comment")
    asserts.false(env, xml.is_cdata(None), "None should not be cdata")
    asserts.false(env, xml.is_document(None), "None should not be document")
    asserts.false(env, xml.is_processing_instruction(None), "None should not be PI")

    return unittest.end(env)

_type_checking_with_none_test = unittest.make(_type_checking_with_none_test_impl)

def type_checking_test_suite(name):
    """Test suite for type checking functions."""
    unittest.suite(
        name,
        _is_document_test,
        _is_element_test,
        _is_text_test,
        _is_comment_test,
        _is_cdata_test,
        _is_processing_instruction_test,
        _type_checking_with_none_test,
    )
