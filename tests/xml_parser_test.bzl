"""Unit tests for the XML parser.
See https://bazel.build/rules/testing#testing-starlark-utilities
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:xml.bzl", "xml")

def _parse_simple_element_test_impl(ctx):
    """Test parsing a simple XML element."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    asserts.true(env, xml.is_document(doc), "Should return a document node")

    root = xml.get_document_element(doc)
    asserts.true(env, root != None, "Document should have a root element")
    asserts.true(env, xml.is_element(root), "Root should be an element")
    asserts.equals(env, "root", xml.get_tag_name(root))

    return unittest.end(env)

_parse_simple_element_test = unittest.make(_parse_simple_element_test_impl)

def _parse_element_with_text_test_impl(ctx):
    """Test parsing an element with text content."""
    env = unittest.begin(ctx)

    doc = xml.parse("<greeting>Hello, World!</greeting>")
    root = xml.get_document_element(doc)

    asserts.equals(env, "greeting", xml.get_tag_name(root))
    asserts.equals(env, "Hello, World!", xml.get_text(root))

    return unittest.end(env)

_parse_element_with_text_test = unittest.make(_parse_element_with_text_test_impl)

def _parse_element_with_attributes_test_impl(ctx):
    """Test parsing an element with attributes."""
    env = unittest.begin(ctx)

    doc = xml.parse('<item id="123" name="test" enabled="true"/>')
    root = xml.get_document_element(doc)

    asserts.equals(env, "item", xml.get_tag_name(root))
    asserts.equals(env, "123", xml.get_attribute(root, "id"))
    asserts.equals(env, "test", xml.get_attribute(root, "name"))
    asserts.equals(env, "true", xml.get_attribute(root, "enabled"))
    asserts.equals(env, None, xml.get_attribute(root, "missing"))
    asserts.equals(env, "default", xml.get_attribute(root, "missing", "default"))

    asserts.true(env, xml.has_attribute(root, "id"))
    asserts.false(env, xml.has_attribute(root, "missing"))

    attrs = xml.get_attributes(root)
    asserts.equals(env, 3, len(attrs))

    return unittest.end(env)

_parse_element_with_attributes_test = unittest.make(_parse_element_with_attributes_test_impl)

def _parse_nested_elements_test_impl(ctx):
    """Test parsing nested elements."""
    env = unittest.begin(ctx)

    xml_str = """
    <root>
        <child1>First</child1>
        <child2>Second</child2>
    </root>
    """
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)

    children = xml.get_child_elements(root)
    asserts.equals(env, 2, len(children))

    asserts.equals(env, "child1", xml.get_tag_name(children[0]))
    asserts.equals(env, "First", xml.get_text(children[0]))

    asserts.equals(env, "child2", xml.get_tag_name(children[1]))
    asserts.equals(env, "Second", xml.get_text(children[1]))

    return unittest.end(env)

_parse_nested_elements_test = unittest.make(_parse_nested_elements_test_impl)

def _find_elements_by_tag_name_test_impl(ctx):
    """Test finding elements by tag name."""
    env = unittest.begin(ctx)

    xml_str = """
    <root>
        <item>One</item>
        <other>X</other>
        <item>Two</item>
        <nested>
            <item>Three</item>
        </nested>
    </root>
    """
    doc = xml.parse(xml_str)

    items = xml.find_elements_by_tag_name(doc, "item")
    asserts.equals(env, 3, len(items))
    asserts.equals(env, "One", xml.get_text(items[0]))
    asserts.equals(env, "Two", xml.get_text(items[1]))
    asserts.equals(env, "Three", xml.get_text(items[2]))

    return unittest.end(env)

_find_elements_by_tag_name_test = unittest.make(_find_elements_by_tag_name_test_impl)

def _find_element_by_id_test_impl(ctx):
    """Test finding an element by id."""
    env = unittest.begin(ctx)

    xml_str = """
    <root>
        <item id="first">One</item>
        <item id="second">Two</item>
        <item id="third">Three</item>
    </root>
    """
    doc = xml.parse(xml_str)

    elem = xml.find_element_by_id(doc, "second")
    asserts.true(env, elem != None, "Should find element with id='second'")
    asserts.equals(env, "Two", xml.get_text(elem))

    missing = xml.find_element_by_id(doc, "missing")
    asserts.true(env, missing == None, "Should return None for missing id")

    return unittest.end(env)

_find_element_by_id_test = unittest.make(_find_element_by_id_test_impl)

def _parse_xml_declaration_test_impl(ctx):
    """Test parsing XML with declaration."""
    env = unittest.begin(ctx)

    xml_str = '<?xml version="1.0" encoding="UTF-8"?><root/>'
    doc = xml.parse(xml_str)

    asserts.true(env, doc.xml_declaration != None, "Should have XML declaration")

    root = xml.get_document_element(doc)
    asserts.equals(env, "root", xml.get_tag_name(root))

    return unittest.end(env)

_parse_xml_declaration_test = unittest.make(_parse_xml_declaration_test_impl)

def _parse_comment_test_impl(ctx):
    """Test parsing XML with comments."""
    env = unittest.begin(ctx)

    xml_str = """
    <root>
        <!-- This is a comment -->
        <item>Value</item>
    </root>
    """
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)

    # Comments are parsed but let's verify the element is still found
    item = xml.find_element_by_tag_name(root, "item")
    asserts.true(env, item != None, "Should find item element")
    asserts.equals(env, "Value", xml.get_text(item))

    return unittest.end(env)

_parse_comment_test = unittest.make(_parse_comment_test_impl)

def _parse_cdata_test_impl(ctx):
    """Test parsing CDATA sections."""
    env = unittest.begin(ctx)

    xml_str = "<code><![CDATA[if (a < b && c > d) { }]]></code>"
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.equals(env, "if (a < b && c > d) { }", text)

    return unittest.end(env)

_parse_cdata_test = unittest.make(_parse_cdata_test_impl)

def _parse_entity_decoding_test_impl(ctx):
    """Test decoding of XML entities."""
    env = unittest.begin(ctx)

    xml_str = "<text>Less &lt; Greater &gt; Amp &amp; Quote &quot; Apos &apos;</text>"
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)

    text = xml.get_text(root)
    asserts.true(env, "<" in text, "Should decode &lt;")
    asserts.true(env, ">" in text, "Should decode &gt;")
    asserts.true(env, "&" in text, "Should decode &amp;")

    return unittest.end(env)

_parse_entity_decoding_test = unittest.make(_parse_entity_decoding_test_impl)

def _entity_double_decoding_regression_test_impl(ctx):
    """Regression test: &amp;lt; should decode to &lt; not <.

    This tests that &amp; is decoded LAST to prevent double-decoding.
    If &amp; is decoded before &lt;, then &amp;lt; becomes &lt; then <.
    The correct behavior is &amp;lt; -> &lt; (literal ampersand + lt;).
    """
    env = unittest.begin(ctx)

    # Test escaped entity references - these should NOT be double-decoded
    xml_str = "<text>&amp;lt; &amp;gt; &amp;amp; &amp;apos; &amp;quot;</text>"
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)
    text = xml.get_text(root)

    # The text should contain the literal entity strings, not decoded characters
    asserts.true(env, "&lt;" in text, "&amp;lt; should decode to &lt; not <")
    asserts.true(env, "&gt;" in text, "&amp;gt; should decode to &gt; not >")
    asserts.true(env, "&amp;" in text, "&amp;amp; should decode to &amp; not &")
    asserts.true(env, "&apos;" in text, "&amp;apos; should decode to &apos; not '")
    asserts.true(env, "&quot;" in text, "&amp;quot; should decode to &quot; not \"")

    # Verify the decoded characters are NOT present (would indicate double-decoding)
    # Note: & will be present from &amp; -> &, so we check for specific sequences
    asserts.false(env, "< " in text, "Should not have double-decoded < from &amp;lt;")
    asserts.false(env, "> " in text, "Should not have double-decoded > from &amp;gt;")

    return unittest.end(env)

_entity_double_decoding_regression_test = unittest.make(_entity_double_decoding_regression_test_impl)

def _to_string_test_impl(ctx):
    """Test serializing back to XML string."""
    env = unittest.begin(ctx)

    xml_str = '<root attr="value"><child>text</child></root>'
    doc = xml.parse(xml_str)

    output = xml.to_string(doc)
    asserts.true(env, "root" in output, "Output should contain root element")
    asserts.true(env, "child" in output, "Output should contain child element")
    asserts.true(env, "text" in output, "Output should contain text content")

    return unittest.end(env)

_to_string_test = unittest.make(_to_string_test_impl)

def _get_children_includes_text_test_impl(ctx):
    """Test that get_children includes text nodes."""
    env = unittest.begin(ctx)

    xml_str = "<root>text<child/>more</root>"
    doc = xml.parse(xml_str)
    root = xml.get_document_element(doc)

    children = xml.get_children(root)

    # Should have text, element, text
    asserts.true(env, len(children) >= 2, "Should have multiple children including text")

    # get_child_elements should only return elements
    elements = xml.get_child_elements(root)
    asserts.equals(env, 1, len(elements))
    asserts.equals(env, "child", xml.get_tag_name(elements[0]))

    return unittest.end(env)

_get_children_includes_text_test = unittest.make(_get_children_includes_text_test_impl)

def _deeply_nested_test_impl(ctx):
    """Test parsing deeply nested XML."""
    env = unittest.begin(ctx)

    xml_str = """
    <level1>
        <level2>
            <level3>
                <level4>
                    <level5>Deep value</level5>
                </level4>
            </level3>
        </level2>
    </level1>
    """
    doc = xml.parse(xml_str)

    level5 = xml.find_element_by_tag_name(doc, "level5")
    asserts.true(env, level5 != None, "Should find deeply nested element")
    asserts.equals(env, "Deep value", xml.get_text(level5))

    return unittest.end(env)

_deeply_nested_test = unittest.make(_deeply_nested_test_impl)

# Error handling tests

def _valid_xml_no_errors_test_impl(ctx):
    """Test that valid XML has no errors."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child>text</child></root>")
    asserts.false(env, xml.has_errors(doc), "Valid XML should have no errors")
    asserts.equals(env, 0, len(xml.get_errors(doc)))

    return unittest.end(env)

_valid_xml_no_errors_test = unittest.make(_valid_xml_no_errors_test_impl)

def _mismatched_tag_error_test_impl(ctx):
    """Test that mismatched tags produce an error."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child></wrong></root>")
    asserts.true(env, xml.has_errors(doc), "Mismatched tags should produce error")

    errors = xml.get_errors(doc)
    asserts.true(env, len(errors) >= 1, "Should have at least one error")

    # Find the mismatched tag error
    found_error = False
    for err in errors:
        if err.type == xml.ERROR_MISMATCHED_TAG:
            found_error = True
            asserts.equals(env, "child", err.expected)
            asserts.equals(env, "wrong", err.found)
    asserts.true(env, found_error, "Should have mismatched tag error")

    return unittest.end(env)

_mismatched_tag_error_test = unittest.make(_mismatched_tag_error_test_impl)

def _unclosed_tag_error_test_impl(ctx):
    """Test that unclosed tags produce an error."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child>")
    asserts.true(env, xml.has_errors(doc), "Unclosed tags should produce error")

    errors = xml.get_errors(doc)
    found_error = False
    for err in errors:
        if err.type == xml.ERROR_UNCLOSED_TAG:
            found_error = True
            asserts.true(env, err.tag_name in ["root", "child"], "Should report unclosed tag name")
    asserts.true(env, found_error, "Should have unclosed tag error")

    return unittest.end(env)

_unclosed_tag_error_test = unittest.make(_unclosed_tag_error_test_impl)

def _unexpected_end_tag_error_test_impl(ctx):
    """Test that unexpected end tags produce an error."""
    env = unittest.begin(ctx)

    doc = xml.parse("</orphan>")
    asserts.true(env, xml.has_errors(doc), "Unexpected end tag should produce error")

    errors = xml.get_errors(doc)
    found_error = False
    for err in errors:
        if err.type == xml.ERROR_UNEXPECTED_END_TAG:
            found_error = True
            asserts.equals(env, "orphan", err.tag_name)
    asserts.true(env, found_error, "Should have unexpected end tag error")

    return unittest.end(env)

_unexpected_end_tag_error_test = unittest.make(_unexpected_end_tag_error_test_impl)

def _multiple_root_elements_error_test_impl(ctx):
    """Test that multiple root elements produce an error."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root1/><root2/>")
    asserts.true(env, xml.has_errors(doc), "Multiple root elements should produce error")

    errors = xml.get_errors(doc)
    found_error = False
    for err in errors:
        if err.type == xml.ERROR_MULTIPLE_ROOT_ELEMENTS:
            found_error = True
            asserts.equals(env, 2, err.count)
    asserts.true(env, found_error, "Should have multiple root elements error")

    return unittest.end(env)

_multiple_root_elements_error_test = unittest.make(_multiple_root_elements_error_test_impl)

def _errors_list_accessible_test_impl(ctx):
    """Test that errors are accessible via doc.errors."""
    env = unittest.begin(ctx)

    doc = xml.parse("<a></b>")  # Mismatched tags
    asserts.true(env, len(doc.errors) > 0, "doc.errors should be populated")
    asserts.true(env, hasattr(doc.errors[0], "type"), "Error should have type field")
    asserts.true(env, hasattr(doc.errors[0], "message"), "Error should have message field")

    return unittest.end(env)

_errors_list_accessible_test = unittest.make(_errors_list_accessible_test_impl)

def _lenient_mode_continues_parsing_test_impl(ctx):
    """Test that lenient mode (default) continues parsing despite errors."""
    env = unittest.begin(ctx)

    # Even with mismatched tags, we should still get a document
    doc = xml.parse("<root><a></b><c>text</c></root>")
    root = xml.get_document_element(doc)
    asserts.true(env, root != None, "Should still parse root element")

    # Should find the 'c' element even after the error
    c_elem = xml.find_element_by_tag_name(doc, "c")
    asserts.true(env, c_elem != None, "Should find element after error")
    asserts.equals(env, "text", xml.get_text(c_elem))

    return unittest.end(env)

_lenient_mode_continues_parsing_test = unittest.make(_lenient_mode_continues_parsing_test_impl)

def _errors_list_isolation_regression_test_impl(ctx):
    """Regression test: each document should have its own independent errors list.

    This tests that the _make_document_node function properly creates a new
    errors list for each document, avoiding mutable default argument issues.
    A previous bug used `errors = []` as a default argument, which could cause
    documents to share the same errors list.
    """
    env = unittest.begin(ctx)

    # Parse two documents - one with errors, one without
    doc_with_errors = xml.parse("<a></b>")  # Mismatched tags
    doc_without_errors = xml.parse("<root/>")  # Valid XML

    # First doc should have errors
    asserts.true(env, xml.has_errors(doc_with_errors), "First doc should have errors")

    # Second doc should NOT have errors (if errors were shared, this would fail)
    asserts.false(env, xml.has_errors(doc_without_errors), "Second doc should NOT have errors")

    # Verify errors are different list objects
    asserts.true(
        env,
        len(doc_with_errors.errors) > 0,
        "First doc's errors list should be non-empty",
    )
    asserts.true(
        env,
        len(doc_without_errors.errors) == 0,
        "Second doc's errors list should be empty",
    )

    return unittest.end(env)

_errors_list_isolation_regression_test = unittest.make(_errors_list_isolation_regression_test_impl)

def _text_outside_root_error_test_impl(ctx):
    """Test that text outside root element produces an error."""
    env = unittest.begin(ctx)

    # Text before root element
    doc = xml.parse("text before<root/>")
    asserts.true(env, xml.has_errors(doc), "Text before root should produce error")

    found_error = False
    for err in xml.get_errors(doc):
        if err.type == xml.ERROR_TEXT_OUTSIDE_ROOT:
            found_error = True
    asserts.true(env, found_error, "Should have text outside root error")

    return unittest.end(env)

_text_outside_root_error_test = unittest.make(_text_outside_root_error_test_impl)

def xml_parser_test_suite(name):
    """Create the test suite for XML parser tests."""
    unittest.suite(
        name,
        _parse_simple_element_test,
        _parse_element_with_text_test,
        _parse_element_with_attributes_test,
        _parse_nested_elements_test,
        _find_elements_by_tag_name_test,
        _find_element_by_id_test,
        _parse_xml_declaration_test,
        _parse_comment_test,
        _parse_cdata_test,
        _parse_entity_decoding_test,
        _entity_double_decoding_regression_test,
        _to_string_test,
        _get_children_includes_text_test,
        _deeply_nested_test,
        # Error handling tests
        _valid_xml_no_errors_test,
        _mismatched_tag_error_test,
        _unclosed_tag_error_test,
        _unexpected_end_tag_error_test,
        _multiple_root_elements_error_test,
        _text_outside_root_error_test,
        _errors_list_accessible_test,
        _lenient_mode_continues_parsing_test,
        _errors_list_isolation_regression_test,
    )
