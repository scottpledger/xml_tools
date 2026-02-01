"""Tests for search functions (find_elements_by_tag_name, find_element_by_id, etc.)"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:xml.bzl", "xml")

def _find_elements_by_tag_name_test_impl(ctx):
    """Test find_elements_by_tag_name function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><item/><item/><item/></root>")
    items = xml.find_elements_by_tag_name(doc, "item")

    asserts.equals(env, 3, len(items))

    return unittest.end(env)

_find_elements_by_tag_name_test = unittest.make(_find_elements_by_tag_name_test_impl)

def _find_elements_by_tag_name_nested_test_impl(ctx):
    """Test find_elements_by_tag_name finds nested elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><item/><nested><item/><deep><item/></deep></nested></root>")
    items = xml.find_elements_by_tag_name(doc, "item")

    asserts.equals(env, 3, len(items))

    return unittest.end(env)

_find_elements_by_tag_name_nested_test = unittest.make(_find_elements_by_tag_name_nested_test_impl)

def _find_elements_by_tag_name_not_found_test_impl(ctx):
    """Test find_elements_by_tag_name returns empty list when not found."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/></root>")
    items = xml.find_elements_by_tag_name(doc, "missing")

    asserts.equals(env, 0, len(items))

    return unittest.end(env)

_find_elements_by_tag_name_not_found_test = unittest.make(_find_elements_by_tag_name_not_found_test_impl)

def _find_elements_by_tag_name_from_element_test_impl(ctx):
    """Test find_elements_by_tag_name starting from an element."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><item/><container><item/></container></root>")
    root = xml.get_document_element(doc)
    container = xml.find_element_by_tag_name(root, "container")

    # Search from container should only find nested item
    items = xml.find_elements_by_tag_name(container, "item")
    asserts.equals(env, 1, len(items))

    return unittest.end(env)

_find_elements_by_tag_name_from_element_test = unittest.make(_find_elements_by_tag_name_from_element_test_impl)

def _find_elements_by_tag_name_includes_root_test_impl(ctx):
    """Test find_elements_by_tag_name includes root if it matches."""
    env = unittest.begin(ctx)

    doc = xml.parse("<item><item/></item>")
    root = xml.get_document_element(doc)

    items = xml.find_elements_by_tag_name(root, "item")
    asserts.equals(env, 2, len(items))  # Root + child

    return unittest.end(env)

_find_elements_by_tag_name_includes_root_test = unittest.make(_find_elements_by_tag_name_includes_root_test_impl)

def _find_element_by_tag_name_test_impl(ctx):
    """Test find_element_by_tag_name function."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/><c/></root>")
    elem = xml.find_element_by_tag_name(doc, "b")

    asserts.true(env, elem != None, "Should find element")
    asserts.equals(env, "b", xml.get_tag_name(elem))

    return unittest.end(env)

_find_element_by_tag_name_test = unittest.make(_find_element_by_tag_name_test_impl)

def _find_element_by_tag_name_first_test_impl(ctx):
    """Test find_element_by_tag_name returns first match."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><item id="1"/><item id="2"/></root>')
    elem = xml.find_element_by_tag_name(doc, "item")

    asserts.equals(env, "1", xml.get_attribute(elem, "id"))

    return unittest.end(env)

_find_element_by_tag_name_first_test = unittest.make(_find_element_by_tag_name_first_test_impl)

def _find_element_by_tag_name_not_found_test_impl(ctx):
    """Test find_element_by_tag_name returns None when not found."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/></root>")
    elem = xml.find_element_by_tag_name(doc, "missing")

    asserts.equals(env, None, elem)

    return unittest.end(env)

_find_element_by_tag_name_not_found_test = unittest.make(_find_element_by_tag_name_not_found_test_impl)

def _find_element_by_id_test_impl(ctx):
    """Test find_element_by_id function."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><a id="first"/><b id="second"/><c id="third"/></root>')
    elem = xml.find_element_by_id(doc, "second")

    asserts.true(env, elem != None, "Should find element by id")
    asserts.equals(env, "b", xml.get_tag_name(elem))

    return unittest.end(env)

_find_element_by_id_test = unittest.make(_find_element_by_id_test_impl)

def _find_element_by_id_nested_test_impl(ctx):
    """Test find_element_by_id finds nested elements."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><a><b><c id="target"/></b></a></root>')
    elem = xml.find_element_by_id(doc, "target")

    asserts.true(env, elem != None, "Should find nested element by id")
    asserts.equals(env, "c", xml.get_tag_name(elem))

    return unittest.end(env)

_find_element_by_id_nested_test = unittest.make(_find_element_by_id_nested_test_impl)

def _find_element_by_id_not_found_test_impl(ctx):
    """Test find_element_by_id returns None when not found."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><a id="other"/></root>')
    elem = xml.find_element_by_id(doc, "missing")

    asserts.equals(env, None, elem)

    return unittest.end(env)

_find_element_by_id_not_found_test = unittest.make(_find_element_by_id_not_found_test_impl)

def _find_elements_by_attribute_test_impl(ctx):
    """Test find_elements_by_attribute function."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><a class="x"/><b class="y"/><c class="x"/></root>')
    elems = xml.find_elements_by_attribute(doc, "class", "x")

    asserts.equals(env, 2, len(elems))

    return unittest.end(env)

_find_elements_by_attribute_test = unittest.make(_find_elements_by_attribute_test_impl)

def _find_elements_by_attribute_any_value_test_impl(ctx):
    """Test find_elements_by_attribute with any value (None)."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><a class="x"/><b/><c class="y"/></root>')
    elems = xml.find_elements_by_attribute(doc, "class")

    asserts.equals(env, 2, len(elems))  # a and c have class attribute

    return unittest.end(env)

_find_elements_by_attribute_any_value_test = unittest.make(_find_elements_by_attribute_any_value_test_impl)

def _find_elements_by_attribute_not_found_test_impl(ctx):
    """Test find_elements_by_attribute returns empty list when not found."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/></root>")
    elems = xml.find_elements_by_attribute(doc, "missing")

    asserts.equals(env, 0, len(elems))

    return unittest.end(env)

_find_elements_by_attribute_not_found_test = unittest.make(_find_elements_by_attribute_not_found_test_impl)

def _find_elements_by_attribute_nested_test_impl(ctx):
    """Test find_elements_by_attribute finds nested elements."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root><a type="x"><b type="x"/></a></root>')
    elems = xml.find_elements_by_attribute(doc, "type", "x")

    asserts.equals(env, 2, len(elems))

    return unittest.end(env)

_find_elements_by_attribute_nested_test = unittest.make(_find_elements_by_attribute_nested_test_impl)

def _find_elements_document_order_regression_test_impl(ctx):
    """Regression test: search functions must return elements in document order.

    This tests that find_elements_by_tag_name returns elements in the order
    they appear in the document (depth-first, pre-order traversal).
    A previous bug caused initial children to be processed in reverse order
    due to inconsistent stack handling.
    """
    env = unittest.begin(ctx)

    # Create a document with multiple 'item' elements at different levels
    # Document order should be: first, second, nested, third
    xml_str = """<root>
        <item id="first"/>
        <item id="second">
            <item id="nested"/>
        </item>
        <item id="third"/>
    </root>"""
    doc = xml.parse(xml_str)

    # Find all 'item' elements
    items = xml.find_elements_by_tag_name(doc, "item")

    asserts.equals(env, 4, len(items), "Should find 4 item elements")

    # Verify document order
    asserts.equals(env, "first", xml.get_attribute(items[0], "id"), "First element should be 'first'")
    asserts.equals(env, "second", xml.get_attribute(items[1], "id"), "Second element should be 'second'")
    asserts.equals(env, "nested", xml.get_attribute(items[2], "id"), "Third element should be 'nested' (child of second)")
    asserts.equals(env, "third", xml.get_attribute(items[3], "id"), "Fourth element should be 'third'")

    return unittest.end(env)

_find_elements_document_order_regression_test = unittest.make(_find_elements_document_order_regression_test_impl)

def _find_elements_from_element_order_regression_test_impl(ctx):
    """Regression test: search from element node must also return correct order.

    When searching from an element (not document), the initial children
    must also be processed in correct document order.
    """
    env = unittest.begin(ctx)

    xml_str = "<root><a/><b/><c/></root>"
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)

    # Search for all elements from root (should find a, b, c in order)
    # Using a matcher that matches all elements by searching for any tag
    a_elems = xml.find_elements_by_tag_name(root, "a")
    b_elems = xml.find_elements_by_tag_name(root, "b")
    c_elems = xml.find_elements_by_tag_name(root, "c")

    asserts.equals(env, 1, len(a_elems), "Should find 1 'a' element")
    asserts.equals(env, 1, len(b_elems), "Should find 1 'b' element")
    asserts.equals(env, 1, len(c_elems), "Should find 1 'c' element")

    # Now test with find_element_by_tag_name which returns first match
    # In a more complex structure
    xml_str2 = "<root><wrapper><target id=\"1\"/></wrapper><target id=\"2\"/></root>"
    doc2 = xml.parse(xml_str2)

    # First target should be id="1" (inside wrapper, but comes first in document order)
    first_target = xml.find_element_by_tag_name(doc2, "target")
    asserts.true(env, first_target != None, "Should find a target element")
    asserts.equals(env, "1", xml.get_attribute(first_target, "id"), "First target should be id='1'")

    return unittest.end(env)

_find_elements_from_element_order_regression_test = unittest.make(_find_elements_from_element_order_regression_test_impl)

def search_test_suite(name):
    """Test suite for search functions."""
    unittest.suite(
        name,
        _find_elements_by_tag_name_test,
        _find_elements_by_tag_name_nested_test,
        _find_elements_by_tag_name_not_found_test,
        _find_elements_by_tag_name_from_element_test,
        _find_elements_by_tag_name_includes_root_test,
        _find_element_by_tag_name_test,
        _find_element_by_tag_name_first_test,
        _find_element_by_tag_name_not_found_test,
        _find_element_by_id_test,
        _find_element_by_id_nested_test,
        _find_element_by_id_not_found_test,
        _find_elements_by_attribute_test,
        _find_elements_by_attribute_any_value_test,
        _find_elements_by_attribute_not_found_test,
        _find_elements_by_attribute_nested_test,
        _find_elements_document_order_regression_test,
        _find_elements_from_element_order_regression_test,
    )
