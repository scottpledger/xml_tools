"""Tests for serialization functions (to_string)"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:xml.bzl", "xml")

def _to_string_simple_test_impl(ctx):
    """Test to_string with simple element."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root/>")
    output = xml.to_string(doc)

    asserts.true(env, "root" in output, "Should contain 'root'")
    asserts.true(env, "<" in output, "Should contain '<'")
    asserts.true(env, ">" in output, "Should contain '>'")

    return unittest.end(env)

_to_string_simple_test = unittest.make(_to_string_simple_test_impl)

def _to_string_with_text_test_impl(ctx):
    """Test to_string preserves text content."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root>Hello World</root>")
    output = xml.to_string(doc)

    asserts.true(env, "Hello World" in output, "Should contain text")

    return unittest.end(env)

_to_string_with_text_test = unittest.make(_to_string_with_text_test_impl)

def _to_string_with_attributes_test_impl(ctx):
    """Test to_string preserves attributes."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root id="123" name="test"/>')
    output = xml.to_string(doc)

    asserts.true(env, "id=" in output, "Should contain id attribute")
    asserts.true(env, "123" in output, "Should contain id value")
    asserts.true(env, "name=" in output, "Should contain name attribute")
    asserts.true(env, "test" in output, "Should contain name value")

    return unittest.end(env)

_to_string_with_attributes_test = unittest.make(_to_string_with_attributes_test_impl)

def _to_string_nested_test_impl(ctx):
    """Test to_string with nested elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child><grandchild/></child></root>")
    output = xml.to_string(doc)

    asserts.true(env, "root" in output, "Should contain root")
    asserts.true(env, "child" in output, "Should contain child")
    asserts.true(env, "grandchild" in output, "Should contain grandchild")

    return unittest.end(env)

_to_string_nested_test = unittest.make(_to_string_nested_test_impl)

def _to_string_with_comment_test_impl(ctx):
    """Test to_string preserves comments."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><!-- my comment --></root>")
    output = xml.to_string(doc)

    asserts.true(env, "<!--" in output, "Should contain comment start")
    asserts.true(env, "-->" in output, "Should contain comment end")
    asserts.true(env, "my comment" in output, "Should contain comment text")

    return unittest.end(env)

_to_string_with_comment_test = unittest.make(_to_string_with_comment_test_impl)

def _to_string_with_cdata_test_impl(ctx):
    """Test to_string preserves CDATA."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><![CDATA[special < > & content]]></root>")
    output = xml.to_string(doc)

    asserts.true(env, "CDATA" in output, "Should contain CDATA marker")

    return unittest.end(env)

_to_string_with_cdata_test = unittest.make(_to_string_with_cdata_test_impl)

def _to_string_with_xml_declaration_test_impl(ctx):
    """Test to_string preserves XML declaration."""
    env = unittest.begin(ctx)

    doc = xml.parse('<?xml version="1.0" encoding="UTF-8"?><root/>')
    output = xml.to_string(doc)

    asserts.true(env, "<?xml" in output, "Should contain XML declaration")

    return unittest.end(env)

_to_string_with_xml_declaration_test = unittest.make(_to_string_with_xml_declaration_test_impl)

def _to_string_escapes_special_chars_test_impl(ctx):
    """Test to_string escapes special characters in text."""
    env = unittest.begin(ctx)

    # Parse, then serialize - special chars in text should be escaped
    doc = xml.parse("<root>a &lt; b</root>")
    output = xml.to_string(doc)

    # After decoding and re-encoding, < should become &lt;
    asserts.true(env, "&lt;" in output, "Should escape < as &lt;")

    return unittest.end(env)

_to_string_escapes_special_chars_test = unittest.make(_to_string_escapes_special_chars_test_impl)

def _to_string_escapes_attribute_quotes_test_impl(ctx):
    """Test to_string escapes quotes in attributes."""
    env = unittest.begin(ctx)

    doc = xml.parse('<root attr="value"/>')
    output = xml.to_string(doc)

    # Attributes should be quoted
    asserts.true(env, 'attr="' in output or "attr='" in output, "Attribute should be quoted")

    return unittest.end(env)

_to_string_escapes_attribute_quotes_test = unittest.make(_to_string_escapes_attribute_quotes_test_impl)

def _to_string_roundtrip_test_impl(ctx):
    """Test that parse->to_string preserves key content."""
    env = unittest.begin(ctx)

    original = '<root id="1"><child name="test">content</child></root>'
    doc = xml.parse(original)
    output = xml.to_string(doc)

    # Parse the output again
    doc2 = xml.parse(output)

    # Find elements in the re-parsed document
    root2 = xml.find_element_by_tag_name(doc2, "root")
    asserts.true(env, root2 != None, "Should find root element after roundtrip")
    asserts.equals(env, "1", xml.get_attribute(root2, "id"))

    child2 = xml.find_element_by_tag_name(doc2, "child")
    asserts.true(env, child2 != None, "Should find child element after roundtrip")
    asserts.equals(env, "test", xml.get_attribute(child2, "name"))
    asserts.equals(env, "content", xml.get_text(child2))

    return unittest.end(env)

_to_string_roundtrip_test = unittest.make(_to_string_roundtrip_test_impl)

def _to_string_self_closing_test_impl(ctx):
    """Test to_string uses self-closing tags for empty elements."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><empty/></root>")
    output = xml.to_string(doc)

    # Empty elements should use self-closing or empty tag
    asserts.true(env, "empty" in output, "Should contain empty element")

    return unittest.end(env)

_to_string_self_closing_test = unittest.make(_to_string_self_closing_test_impl)

def _to_string_element_only_test_impl(ctx):
    """Test to_string works on element node directly."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child>text</child></root>")
    root = xml.get_document_element(doc)
    child = xml.get_first_child_element(root)

    output = xml.to_string(child)
    asserts.true(env, "child" in output, "Should contain child element")
    asserts.true(env, "text" in output, "Should contain text content")

    return unittest.end(env)

_to_string_element_only_test = unittest.make(_to_string_element_only_test_impl)

def _to_string_processing_instruction_test_impl(ctx):
    """Test to_string preserves processing instructions."""
    env = unittest.begin(ctx)

    doc = xml.parse("<?target data?><root/>")
    output = xml.to_string(doc)

    asserts.true(env, "<?" in output, "Should contain PI start")
    asserts.true(env, "?>" in output, "Should contain PI end")
    asserts.true(env, "target" in output, "Should contain PI target")

    return unittest.end(env)

_to_string_processing_instruction_test = unittest.make(_to_string_processing_instruction_test_impl)

def _to_string_indent_test_impl(ctx):
    """Test to_string with indentation."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child><grandchild/></child></root>")
    output = xml.to_string(doc)

    # Check that nested elements are indented
    lines = output.split("\n")

    # Should have multiple lines for nested structure
    asserts.true(env, len(lines) >= 3, "Indented output should have multiple lines")

    # Look for indentation in child elements
    has_indented_child = False
    has_indented_grandchild = False
    for line in lines:
        if "  <child" in line or "\t<child" in line:
            has_indented_child = True
        if "    <grandchild" in line or "\t\t<grandchild" in line:
            has_indented_grandchild = True

    asserts.true(env, has_indented_child, "Child should be indented")
    asserts.true(env, has_indented_grandchild, "Grandchild should be doubly indented")

    return unittest.end(env)

_to_string_indent_test = unittest.make(_to_string_indent_test_impl)

def _to_string_custom_indent_str_test_impl(ctx):
    """Test to_string with custom indent string."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child/></root>")
    output = xml.to_string(doc, indent_str = "    ")  # 4 spaces

    # Verify child is indented with 4 spaces
    asserts.true(env, "    <child" in output, "Child should be indented with 4 spaces")

    return unittest.end(env)

_to_string_custom_indent_str_test = unittest.make(_to_string_custom_indent_str_test_impl)

def _to_string_text_inline_test_impl(ctx):
    """Test to_string keeps text content inline."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child>text content</child></root>")
    output = xml.to_string(doc)

    # Text content should stay inline with its parent element
    asserts.true(env, "<child>text content</child>" in output, "Text content should be inline")

    return unittest.end(env)

_to_string_text_inline_test = unittest.make(_to_string_text_inline_test_impl)

def _to_string_compact_test_impl(ctx):
    """Test to_string with pretty=False produces compact output."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child><grandchild/></child></root>")
    output = xml.to_string(doc, pretty = False)

    # Compact output should have no newlines
    asserts.false(env, "\n" in output, "Compact output should not contain newlines")

    # Should still contain all elements
    asserts.true(env, "<root>" in output, "Should contain root")
    asserts.true(env, "<child>" in output, "Should contain child")
    asserts.true(env, "<grandchild/>" in output, "Should contain grandchild")

    # Should be a single line
    expected = "<root><child><grandchild/></child></root>"
    asserts.equals(env, expected, output)

    return unittest.end(env)

_to_string_compact_test = unittest.make(_to_string_compact_test_impl)

def _to_string_compact_with_text_test_impl(ctx):
    """Test to_string compact with text content."""
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child>hello</child></root>")
    output = xml.to_string(doc, pretty = False)

    expected = "<root><child>hello</child></root>"
    asserts.equals(env, expected, output)

    return unittest.end(env)

_to_string_compact_with_text_test = unittest.make(_to_string_compact_with_text_test_impl)

def _nested_serialization_regression_test_impl(ctx):
    """Regression test: nested elements must be properly contained in pretty output.

    This tests that the indented serializer properly nests child elements inside
    their parents. A previous bug caused output like:
        <child/>
        <root></root>
    instead of:
        <root>
          <child/>
        </root>
    """
    env = unittest.begin(ctx)

    doc = xml.parse("<root><child><grandchild/></child></root>")
    output = xml.to_string(doc)

    # Verify the structure is correct by checking element order and containment
    root_open = output.find("<root>")
    child_open = output.find("<child>")
    grandchild = output.find("<grandchild/>")
    child_close = output.find("</child>")
    root_close = output.find("</root>")

    # All elements should be found
    asserts.true(env, root_open >= 0, "Should find <root>")
    asserts.true(env, child_open >= 0, "Should find <child>")
    asserts.true(env, grandchild >= 0, "Should find <grandchild/>")
    asserts.true(env, child_close >= 0, "Should find </child>")
    asserts.true(env, root_close >= 0, "Should find </root>")

    # Verify proper nesting order: root opens, child opens, grandchild, child closes, root closes
    asserts.true(env, root_open < child_open, "<root> should come before <child>")
    asserts.true(env, child_open < grandchild, "<child> should come before <grandchild/>")
    asserts.true(env, grandchild < child_close, "<grandchild/> should come before </child>")
    asserts.true(env, child_close < root_close, "</child> should come before </root>")

    # Re-parse the output and verify structure is preserved
    doc2 = xml.parse(output)
    root2 = xml.get_document_element(doc2)
    asserts.equals(env, "root", xml.get_tag_name(root2))

    child2 = xml.get_first_child_element(root2)
    asserts.true(env, child2 != None, "Re-parsed doc should have child element")
    asserts.equals(env, "child", xml.get_tag_name(child2))

    grandchild2 = xml.get_first_child_element(child2)
    asserts.true(env, grandchild2 != None, "Re-parsed doc should have grandchild element")
    asserts.equals(env, "grandchild", xml.get_tag_name(grandchild2))

    return unittest.end(env)

_nested_serialization_regression_test = unittest.make(_nested_serialization_regression_test_impl)

def _sibling_elements_newlines_regression_test_impl(ctx):
    """Regression test: sibling elements should each be on their own line in pretty print.

    This tests that pretty-printed output places sibling elements on separate lines,
    not on the same line. A previous bug caused <a/> and <b/> to appear as
    "  <a/>  <b/>" on one line instead of separate lines.
    """
    env = unittest.begin(ctx)

    doc = xml.parse("<root><a/><b/><c/></root>")
    output = xml.to_string(doc, pretty = True)

    # Each sibling element should be on its own line
    # The output should look like:
    # <root>
    #   <a/>
    #   <b/>
    #   <c/>
    # </root>

    lines = output.split("\n")

    # Should have 5 lines: <root>, <a/>, <b/>, <c/>, </root>
    asserts.equals(env, 5, len(lines), "Should have 5 lines for root with 3 self-closing children")

    # Verify structure
    asserts.true(env, lines[0].strip() == "<root>", "Line 1 should be <root>")
    asserts.true(env, lines[1].strip() == "<a/>", "Line 2 should be <a/>")
    asserts.true(env, lines[2].strip() == "<b/>", "Line 3 should be <b/>")
    asserts.true(env, lines[3].strip() == "<c/>", "Line 4 should be <c/>")
    asserts.true(env, lines[4].strip() == "</root>", "Line 5 should be </root>")

    return unittest.end(env)

_sibling_elements_newlines_regression_test = unittest.make(_sibling_elements_newlines_regression_test_impl)

def _sibling_elements_with_children_regression_test_impl(ctx):
    """Regression test: sibling elements with children also need proper newlines.

    Tests the case from README where setting elements should be on separate lines.
    """
    env = unittest.begin(ctx)

    xml_str = "<config><setting name=\"debug\">true</setting><setting name=\"timeout\">30</setting></config>"
    doc = xml.parse(xml_str)
    output = xml.to_string(doc, pretty = True)

    # Each setting element should be on its own line
    # <config>
    #   <setting name="debug">true</setting>
    #   <setting name="timeout">30</setting>
    # </config>

    lines = output.split("\n")

    asserts.equals(env, 4, len(lines), "Should have 4 lines")

    # Verify first setting is on line 2, second setting on line 3
    asserts.true(env, "<setting" in lines[1], "Line 2 should contain first setting")
    asserts.true(env, "debug" in lines[1], "Line 2 should contain debug setting")
    asserts.true(env, "<setting" in lines[2], "Line 3 should contain second setting")
    asserts.true(env, "timeout" in lines[2], "Line 3 should contain timeout setting")

    # Make sure they're not on the same line
    asserts.false(env, "debug" in lines[2], "Debug setting should NOT be on line 3")
    asserts.false(env, "timeout" in lines[1], "Timeout setting should NOT be on line 2")

    return unittest.end(env)

_sibling_elements_with_children_regression_test = unittest.make(_sibling_elements_with_children_regression_test_impl)

def serialization_test_suite(name):
    """Test suite for serialization functions."""
    unittest.suite(
        name,
        _to_string_simple_test,
        _to_string_with_text_test,
        _to_string_with_attributes_test,
        _to_string_nested_test,
        _to_string_with_comment_test,
        _to_string_with_cdata_test,
        _to_string_with_xml_declaration_test,
        _to_string_escapes_special_chars_test,
        _to_string_escapes_attribute_quotes_test,
        _to_string_roundtrip_test,
        _to_string_self_closing_test,
        _to_string_element_only_test,
        _to_string_processing_instruction_test,
        _to_string_indent_test,
        _to_string_custom_indent_str_test,
        _to_string_text_inline_test,
        _to_string_compact_test,
        _to_string_compact_with_text_test,
        _nested_serialization_regression_test,
        _sibling_elements_newlines_regression_test,
        _sibling_elements_with_children_regression_test,
    )
