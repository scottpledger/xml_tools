"Tests for XML builder functions"

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:xml.bzl", "xml")

def _element_basic_test_impl(ctx):
    env = unittest.begin(ctx)

    elem = xml.element("div")
    asserts.equals(env, "div", xml.get_tag_name(elem))
    asserts.equals(env, {}, xml.get_attributes(elem))
    asserts.equals(env, [], xml.get_children(elem))

    return unittest.end(env)

_element_basic_test = unittest.make(_element_basic_test_impl)

def _element_with_attributes_test_impl(ctx):
    env = unittest.begin(ctx)

    elem = xml.element("div", {"class": "container", "id": "main"})
    asserts.equals(env, "container", xml.get_attribute(elem, "class"))
    asserts.equals(env, "main", xml.get_attribute(elem, "id"))

    return unittest.end(env)

_element_with_attributes_test = unittest.make(_element_with_attributes_test_impl)

def _element_with_children_test_impl(ctx):
    env = unittest.begin(ctx)

    child = xml.element("span")
    parent = xml.element("div", children = [child])
    asserts.equals(env, 1, xml.count_child_elements(parent))

    return unittest.end(env)

_element_with_children_test = unittest.make(_element_with_children_test_impl)

def _text_node_test_impl(ctx):
    env = unittest.begin(ctx)

    t = xml.text("Hello, world!")
    asserts.true(env, xml.is_text(t))
    asserts.equals(env, "Hello, world!", t.content)

    return unittest.end(env)

_text_node_test = unittest.make(_text_node_test_impl)

def _comment_node_test_impl(ctx):
    env = unittest.begin(ctx)

    c = xml.comment("This is a comment")
    asserts.true(env, xml.is_comment(c))
    asserts.equals(env, "This is a comment", c.content)

    return unittest.end(env)

_comment_node_test = unittest.make(_comment_node_test_impl)

def _cdata_node_test_impl(ctx):
    env = unittest.begin(ctx)

    cd = xml.cdata("<script>alert('hi')</script>")
    asserts.true(env, xml.is_cdata(cd))
    asserts.equals(env, "<script>alert('hi')</script>", cd.content)

    return unittest.end(env)

_cdata_node_test = unittest.make(_cdata_node_test_impl)

def _document_node_test_impl(ctx):
    env = unittest.begin(ctx)

    root = xml.element("root")
    doc = xml.document(children = [root])
    asserts.true(env, xml.is_document(doc))
    asserts.equals(env, 1, len(doc.children))

    return unittest.end(env)

_document_node_test = unittest.make(_document_node_test_impl)

def _document_with_declaration_test_impl(ctx):
    env = unittest.begin(ctx)

    root = xml.element("root")
    doc = xml.document(
        xml_declaration = 'version="1.0" encoding="utf-8"',
        children = [root],
    )
    asserts.equals(env, 'version="1.0" encoding="utf-8"', doc.xml_declaration)

    return unittest.end(env)

_document_with_declaration_test = unittest.make(_document_with_declaration_test_impl)

def _serialize_element_test_impl(ctx):
    env = unittest.begin(ctx)

    elem = xml.element("div", {"class": "test"}, [
        xml.text("Hello"),
    ])
    result = xml.to_string(elem, pretty = False)
    asserts.equals(env, '<div class="test">Hello</div>', result)

    return unittest.end(env)

_serialize_element_test = unittest.make(_serialize_element_test_impl)

def _serialize_nested_test_impl(ctx):
    env = unittest.begin(ctx)

    elem = xml.element("root", children = [
        xml.element("child", children = [
            xml.text("content"),
        ]),
    ])
    result = xml.to_string(elem, pretty = False)
    asserts.equals(env, "<root><child>content</child></root>", result)

    return unittest.end(env)

_serialize_nested_test = unittest.make(_serialize_nested_test_impl)

def _serialize_self_closing_test_impl(ctx):
    env = unittest.begin(ctx)

    elem = xml.element("br")
    result = xml.to_string(elem, pretty = False)
    asserts.equals(env, "<br/>", result)

    return unittest.end(env)

_serialize_self_closing_test = unittest.make(_serialize_self_closing_test_impl)

def _serialize_escapes_text_test_impl(ctx):
    env = unittest.begin(ctx)

    elem = xml.element("p", children = [
        xml.text("Hello <world> & \"friends\""),
    ])
    result = xml.to_string(elem, pretty = False)
    asserts.equals(env, "<p>Hello &lt;world&gt; &amp; &quot;friends&quot;</p>", result)

    return unittest.end(env)

_serialize_escapes_text_test = unittest.make(_serialize_escapes_text_test_impl)

def _serialize_document_test_impl(ctx):
    env = unittest.begin(ctx)

    doc = xml.document(
        xml_declaration = 'version="1.0" encoding="utf-8"',
        children = [
            xml.element("root"),
        ],
    )
    result = xml.to_string(doc, pretty = False)
    asserts.equals(env, '<?xml version="1.0" encoding="utf-8"?><root/>', result)

    return unittest.end(env)

_serialize_document_test = unittest.make(_serialize_document_test_impl)

def _processing_instruction_test_impl(ctx):
    env = unittest.begin(ctx)

    pi = xml.processing_instruction("xml-stylesheet", 'type="text/xsl" href="style.xsl"')
    asserts.true(env, xml.is_processing_instruction(pi))
    asserts.equals(env, "xml-stylesheet", pi.target)

    return unittest.end(env)

_processing_instruction_test = unittest.make(_processing_instruction_test_impl)

def builder_test_suite(name):
    """Create the test suite for builder tests."""
    unittest.suite(
        name,
        _element_basic_test,
        _element_with_attributes_test,
        _element_with_children_test,
        _text_node_test,
        _comment_node_test,
        _cdata_node_test,
        _document_node_test,
        _document_with_declaration_test,
        _serialize_element_test,
        _serialize_nested_test,
        _serialize_self_closing_test,
        _serialize_escapes_text_test,
        _serialize_document_test,
        _processing_instruction_test,
    )
