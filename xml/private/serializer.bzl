"""XML serialization functions."""

load(
    ":dom.bzl",
    "is_cdata",
    "is_comment",
    "is_document",
    "is_element",
    "is_processing_instruction",
    "is_text",
)

def _encode_entities(text):
    """Encode special characters as XML entities."""
    result = text
    result = result.replace("&", "&amp;")
    result = result.replace("<", "&lt;")
    result = result.replace(">", "&gt;")
    result = result.replace('"', "&quot;")
    return result

def _attrs_to_string(attributes):
    """Convert attributes dict to string."""
    if not attributes:
        return ""
    parts = []
    for name, value in attributes.items():
        parts.append(' {}="{}"'.format(name, _encode_entities(value)))
    return "".join(parts)

def _non_element_to_string(node):
    """Convert a non-element node (text, comment, CDATA, PI) to string."""
    if is_text(node):
        return _encode_entities(node.content)
    if is_comment(node):
        return "<!--" + node.content + "-->"
    if is_cdata(node):
        return "<![CDATA[" + node.content + "]]>"
    if is_processing_instruction(node):
        return "<?" + node.target + " " + node.content + "?>"
    return ""

def _node_to_string_simple(node):
    """Convert any node to string (delegates to appropriate handler)."""
    if is_element(node):
        return _element_to_string_compact(node)
    return _non_element_to_string(node)

def _element_to_string_compact(element):
    """Convert an element and its descendants to compact string (no indentation).

    Uses a stack-based approach with string markers for closing tags.
    When we encounter an element, we output the opening tag immediately,
    then push the closing tag and children onto the stack.
    """
    result = []
    stack = [element]

    for _ in range(100000):
        if not stack:
            break

        item = stack.pop()

        # Check if it's a string marker (closing tag)
        if type(item) == "string":
            result.append(item)
            continue

        # Handle element nodes specially for stack-based traversal
        if is_element(item):
            attrs_str = _attrs_to_string(item.attributes)
            if not item.children:
                # Self-closing tag
                result.append("<" + item.tag_name + attrs_str + "/>")
            else:
                # Output opening tag
                result.append("<" + item.tag_name + attrs_str + ">")

                # Push closing tag marker
                stack.append("</" + item.tag_name + ">")

                # Push children in reverse order (so first child is processed first)
                for i in range(len(item.children) - 1, -1, -1):
                    stack.append(item.children[i])
        else:
            # Non-element nodes can be converted directly
            result.append(_non_element_to_string(item))

    return "".join(result)

def _to_string_compact(node):
    """Convert a node to compact XML string without formatting."""
    if is_document(node):
        parts = []
        if node.xml_declaration:
            parts.append("<?xml " + node.xml_declaration + "?>")
        if node.doctype:
            parts.append("<!DOCTYPE " + node.doctype + ">")
        for child in node.children:
            parts.append(_node_to_string_simple(child))
        return "".join(parts)

    return _node_to_string_simple(node)

def _element_to_string_indented(element, indent, indent_str):
    """Convert an element and its descendants to string with indentation.

    Uses a stack-based approach similar to the compact version but with
    indentation tracking. Uses string markers for closing tags.

    Stack items can be:
    - (node, indent_level, needs_newline): A node to process
    - ("close", tag_name, indent_level, has_element_children): A closing tag marker
    """
    result = []

    # Initial element doesn't need a preceding newline
    stack = [(element, indent, False)]

    for _ in range(100000):
        if not stack:
            break

        item = stack.pop()

        # Check if it's a closing tag marker
        if type(item) == "tuple" and len(item) == 4 and item[0] == "close":
            _, tag_name, close_indent, has_element_children = item
            prefix = indent_str * close_indent
            if has_element_children:
                result.append("\n" + prefix + "</" + tag_name + ">")
            else:
                result.append("</" + tag_name + ">")
            continue

        node, current_indent, needs_newline = item
        prefix = indent_str * current_indent

        if is_element(node):
            attrs_str = _attrs_to_string(node.attributes)
            newline_prefix = "\n" + prefix if needs_newline else prefix

            if not node.children:
                # Self-closing tag
                result.append(newline_prefix + "<" + node.tag_name + attrs_str + "/>")
            else:
                # Check if all children are inline (text/cdata only)
                has_element_children = False
                for child in node.children:
                    if is_element(child) or is_comment(child) or is_processing_instruction(child):
                        has_element_children = True
                        break

                # Output opening tag
                result.append(newline_prefix + "<" + node.tag_name + attrs_str + ">")

                # Push closing tag marker
                stack.append(("close", node.tag_name, current_indent, has_element_children))

                # Push children in reverse order
                # All children in an element with element children need newlines
                for i in range(len(node.children) - 1, -1, -1):
                    stack.append((node.children[i], current_indent + 1, has_element_children))
        elif is_text(node):
            result.append(_encode_entities(node.content))
        elif is_comment(node):
            newline_prefix = "\n" + prefix if needs_newline else prefix
            result.append(newline_prefix + "<!--" + node.content + "-->")
        elif is_cdata(node):
            result.append("<![CDATA[" + node.content + "]]>")
        elif is_processing_instruction(node):
            newline_prefix = "\n" + prefix if needs_newline else prefix
            result.append(newline_prefix + "<?" + node.target + " " + node.content + "?>")

    return "".join(result)

def to_string(node, indent = 0, indent_str = "  ", pretty = True):
    """
    Convert a node back to an XML string.

    Args:
        node: The node to serialize.
        indent: Current indentation level (default 0). Only used when pretty=True.
        indent_str: String to use for each level of indentation (default "  ").
            Only used when pretty=True.
        pretty: If True (default), format output with indentation and newlines.
            If False, produce compact output with no extra whitespace.

    Returns:
        An XML string representation of the node.
    """
    if not pretty:
        return _to_string_compact(node)

    if is_document(node):
        parts = []
        if node.xml_declaration:
            parts.append("<?xml " + node.xml_declaration + "?>")
        if node.doctype:
            parts.append("<!DOCTYPE " + node.doctype + ">")
        for child in node.children:
            if is_element(child):
                parts.append(_element_to_string_indented(child, indent, indent_str))
            else:
                parts.append(_node_to_string_simple(child))
        return "\n".join(parts)

    if is_text(node):
        return _encode_entities(node.content)

    if is_comment(node):
        prefix = indent_str * indent
        return prefix + "<!--" + node.content + "-->"

    if is_cdata(node):
        return "<![CDATA[" + node.content + "]]>"

    if is_processing_instruction(node):
        prefix = indent_str * indent
        return prefix + "<?" + node.target + " " + node.content + "?>"

    if is_element(node):
        return _element_to_string_indented(node, indent, indent_str)

    return ""
