"""Tests for element access functions (get_tag_name, get_attribute, etc.)"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:xml.bzl", "xml")

def _get_tag_name_test_impl(ctx):
    """Test get_tag_name function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<myElement/>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "myElement", xml.get_tag_name(root))

    return unittest.end(env)

_get_tag_name_test = unittest.make(_get_tag_name_test_impl)

def _get_tag_name_with_namespace_prefix_test_impl(ctx):
    """Test get_tag_name with namespace prefix."""
    env = unittest.begin(ctx)

    doc = xml.parse("<ns:element/>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "ns:element", xml.get_tag_name(root))

    return unittest.end(env)

_get_tag_name_with_namespace_prefix_test = unittest.make(_get_tag_name_with_namespace_prefix_test_impl)

def _get_tag_name_on_non_element_test_impl(ctx):
    """Test get_tag_name returns None for non-elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    asserts.equals(env, None, xml.get_tag_name(doc))

    return unittest.end(env)

_get_tag_name_on_non_element_test = unittest.make(_get_tag_name_on_non_element_test_impl)

def _get_attribute_test_impl(ctx):
    """Test get_attribute function."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item id="123" name="test"/>')
    root = xml.get_document_element(doc)

    asserts.equals(env, "123", xml.get_attribute(root, "id"))
    asserts.equals(env, "test", xml.get_attribute(root, "name"))

    return unittest.end(env)

_get_attribute_test = unittest.make(_get_attribute_test_impl)

def _get_attribute_missing_test_impl(ctx):
    """Test get_attribute with missing attribute."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item id="123"/>')
    root = xml.get_document_element(doc)

    asserts.equals(env, None, xml.get_attribute(root, "missing"))

    return unittest.end(env)

_get_attribute_missing_test = unittest.make(_get_attribute_missing_test_impl)

def _get_attribute_default_test_impl(ctx):
    """Test get_attribute with default value."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item id="123"/>')
    root = xml.get_document_element(doc)

    asserts.equals(env, "default_value", xml.get_attribute(root, "missing", "default_value"))
    asserts.equals(env, "123", xml.get_attribute(root, "id", "default_value"))

    return unittest.end(env)

_get_attribute_default_test = unittest.make(_get_attribute_default_test_impl)

def _get_attribute_with_entities_test_impl(ctx):
    """Test get_attribute decodes entities."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item value="a &lt; b &amp; c &gt; d"/>')
    root = xml.get_document_element(doc)

    value = xml.get_attribute(root, "value")
    asserts.true(env, "<" in value, "Should decode &lt;")
    asserts.true(env, "&" in value, "Should decode &amp;")
    asserts.true(env, ">" in value, "Should decode &gt;")

    return unittest.end(env)

_get_attribute_with_entities_test = unittest.make(_get_attribute_with_entities_test_impl)

def _get_attribute_on_non_element_test_impl(ctx):
    """Test get_attribute returns default for non-elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    asserts.equals(env, None, xml.get_attribute(doc, "attr"))
    asserts.equals(env, "default", xml.get_attribute(doc, "attr", "default"))

    return unittest.end(env)

_get_attribute_on_non_element_test = unittest.make(_get_attribute_on_non_element_test_impl)

def _get_attributes_test_impl(ctx):
    """Test get_attributes function."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item a="1" b="2" c="3"/>')
    root = xml.get_document_element(doc)

    attrs = xml.get_attributes(root)
    asserts.equals(env, 3, len(attrs))
    asserts.equals(env, "1", attrs["a"])
    asserts.equals(env, "2", attrs["b"])
    asserts.equals(env, "3", attrs["c"])

    return unittest.end(env)

_get_attributes_test = unittest.make(_get_attributes_test_impl)

def _get_attributes_empty_test_impl(ctx):
    """Test get_attributes with no attributes."""
    env = unittest.begin(ctx)

    doc = xml.parse("<item/>")
    root = xml.get_document_element(doc)

    attrs = xml.get_attributes(root)
    asserts.equals(env, 0, len(attrs))

    return unittest.end(env)

_get_attributes_empty_test = unittest.make(_get_attributes_empty_test_impl)

def _get_attributes_on_non_element_test_impl(ctx):
    """Test get_attributes returns empty dict for non-elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    attrs = xml.get_attributes(doc)
    asserts.equals(env, 0, len(attrs))

    return unittest.end(env)

_get_attributes_on_non_element_test = unittest.make(_get_attributes_on_non_element_test_impl)

def _has_attribute_test_impl(ctx):
    """Test has_attribute function."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item id="123"/>')
    root = xml.get_document_element(doc)

    asserts.true(env, xml.has_attribute(root, "id"))
    asserts.false(env, xml.has_attribute(root, "missing"))

    return unittest.end(env)

_has_attribute_test = unittest.make(_has_attribute_test_impl)

def _has_attribute_on_non_element_test_impl(ctx):
    """Test has_attribute returns False for non-elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    asserts.false(env, xml.has_attribute(doc, "attr"))

    return unittest.end(env)

_has_attribute_on_non_element_test = unittest.make(_has_attribute_on_non_element_test_impl)

def _attribute_with_quotes_test_impl(ctx):
    """Test attributes with different quote styles."""
    env = unittest.begin(ctx)

    # Double quotes
    doc1 = xml.parse('<item attr="value"/>')
    root1 = xml.get_document_element(doc1)
    asserts.equals(env, "value", xml.get_attribute(root1, "attr"))

    # Single quotes
    doc2 = xml.parse("<item attr='value'/>")
    root2 = xml.get_document_element(doc2)
    asserts.equals(env, "value", xml.get_attribute(root2, "attr"))

    return unittest.end(env)

_attribute_with_quotes_test = unittest.make(_attribute_with_quotes_test_impl)

def element_access_test_suite(name):
    """Test suite for element access functions."""
    unittest.suite(
        name,
        _get_tag_name_test,
        _get_tag_name_with_namespace_prefix_test,
        _get_tag_name_on_non_element_test,
        _get_attribute_test,
        _get_attribute_missing_test,
        _get_attribute_default_test,
        _get_attribute_with_entities_test,
        _get_attribute_on_non_element_test,
        _get_attributes_test,
        _get_attributes_empty_test,
        _get_attributes_on_non_element_test,
        _has_attribute_test,
        _has_attribute_on_non_element_test,
        _attribute_with_quotes_test,
    )
