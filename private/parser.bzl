"XML parser that builds a DOM tree from tokens"

load("//private:tokenizer.bzl", "TOKEN_CDATA", "TOKEN_COMMENT", "TOKEN_DOCTYPE", "TOKEN_END_TAG", "TOKEN_PI", "TOKEN_SELF_CLOSING", "TOKEN_START_TAG", "TOKEN_TEXT", "TOKEN_XML_DECL", "tokenize")

# Node types for the DOM tree
NODE_ELEMENT = "element"
NODE_TEXT = "text"
NODE_COMMENT = "comment"
NODE_CDATA = "cdata"
NODE_PROCESSING_INSTRUCTION = "processing_instruction"
NODE_DOCUMENT = "document"

# Error types
ERROR_MISMATCHED_TAG = "mismatched_tag"
ERROR_UNCLOSED_TAG = "unclosed_tag"
ERROR_UNEXPECTED_END_TAG = "unexpected_end_tag"
ERROR_MULTIPLE_ROOT_ELEMENTS = "multiple_root_elements"
ERROR_TEXT_OUTSIDE_ROOT = "text_outside_root"

def _make_error(error_type, message, **kwargs):
    """Create an error struct."""
    return struct(
        type = error_type,
        message = message,
        **kwargs
    )

def _make_element_node(name, attributes, children, parent = None):
    """Create an element node."""
    return struct(
        node_type = NODE_ELEMENT,
        tag_name = name,
        attributes = attributes,
        children = children,
        parent = parent,
    )

def _make_text_node(content, parent = None):
    """Create a text node."""
    return struct(
        node_type = NODE_TEXT,
        content = content,
        parent = parent,
    )

def _make_comment_node(content, parent = None):
    """Create a comment node."""
    return struct(
        node_type = NODE_COMMENT,
        content = content,
        parent = parent,
    )

def _make_cdata_node(content, parent = None):
    """Create a CDATA node."""
    return struct(
        node_type = NODE_CDATA,
        content = content,
        parent = parent,
    )

def _make_pi_node(target, content, parent = None):
    """Create a processing instruction node."""
    return struct(
        node_type = NODE_PROCESSING_INSTRUCTION,
        target = target,
        content = content,
        parent = parent,
    )

def _make_document_node(children, xml_declaration = None, doctype = None, errors = None):
    """Create a document node."""
    return struct(
        node_type = NODE_DOCUMENT,
        children = children,
        xml_declaration = xml_declaration,
        doctype = doctype,
        errors = errors if errors != None else [],
    )

def _build_tree(tokens):
    """
    Build a DOM tree from a list of tokens.

    Returns a tuple of (root_nodes, xml_declaration, doctype, errors).
    """
    root_nodes = []
    stack = []  # Stack of (node, children_list) tuples
    xml_declaration = None
    doctype = None
    errors = []
    root_element_count = 0

    for token in tokens:
        if token.type == TOKEN_XML_DECL:
            xml_declaration = token.content

        elif token.type == TOKEN_DOCTYPE:
            doctype = token.content

        elif token.type == TOKEN_START_TAG:
            # Create element with empty children list
            children = []
            parent = stack[-1][0] if stack else None
            node = _make_element_node(token.name, token.attributes, children, parent)

            if stack:
                # Add to parent's children
                _, parent_children = stack[-1]
                parent_children.append(node)

            # Push onto stack
            stack.append((node, children))

        elif token.type == TOKEN_END_TAG:
            if stack:
                node, _ = stack.pop()

                # Verify tag name matches
                if node.tag_name != token.name:
                    errors.append(_make_error(
                        ERROR_MISMATCHED_TAG,
                        "Mismatched closing tag: expected </%s>, found </%s>" % (node.tag_name, token.name),
                        expected = node.tag_name,
                        found = token.name,
                    ))

                # If stack is now empty, this is a root element
                if not stack:
                    root_nodes.append(node)
                    root_element_count += 1
            else:
                # End tag without matching start tag
                errors.append(_make_error(
                    ERROR_UNEXPECTED_END_TAG,
                    "Unexpected closing tag </%s> with no matching opening tag" % token.name,
                    tag_name = token.name,
                ))

        elif token.type == TOKEN_SELF_CLOSING:
            parent = stack[-1][0] if stack else None
            node = _make_element_node(token.name, token.attributes, [], parent)

            if stack:
                _, parent_children = stack[-1]
                parent_children.append(node)
            else:
                root_nodes.append(node)
                root_element_count += 1

        elif token.type == TOKEN_TEXT:
            parent = stack[-1][0] if stack else None
            node = _make_text_node(token.content, parent)

            if stack:
                _, parent_children = stack[-1]
                parent_children.append(node)
            else:
                # Text outside root element - only add if non-whitespace
                if token.content.strip():
                    root_nodes.append(node)
                    errors.append(_make_error(
                        ERROR_TEXT_OUTSIDE_ROOT,
                        "Non-whitespace text content outside root element",
                        content = token.content.strip()[:50],  # Truncate for readability
                    ))

        elif token.type == TOKEN_COMMENT:
            parent = stack[-1][0] if stack else None
            node = _make_comment_node(token.content, parent)

            if stack:
                _, parent_children = stack[-1]
                parent_children.append(node)
            else:
                root_nodes.append(node)

        elif token.type == TOKEN_CDATA:
            parent = stack[-1][0] if stack else None
            node = _make_cdata_node(token.content, parent)

            if stack:
                _, parent_children = stack[-1]
                parent_children.append(node)
            else:
                root_nodes.append(node)

        elif token.type == TOKEN_PI:
            parent = stack[-1][0] if stack else None
            node = _make_pi_node(token.target, token.content, parent)

            if stack:
                _, parent_children = stack[-1]
                parent_children.append(node)
            else:
                root_nodes.append(node)

    # Handle unclosed tags - pop remaining items from stack
    # Using for loop since Starlark doesn't support while
    for _ in range(len(tokens) + 1):
        if not stack:
            break
        node, _ = stack.pop()
        errors.append(_make_error(
            ERROR_UNCLOSED_TAG,
            "Unclosed tag <%s>" % node.tag_name,
            tag_name = node.tag_name,
        ))
        if not stack:
            root_nodes.append(node)
            root_element_count += 1

    # Check for multiple root elements
    if root_element_count > 1:
        errors.append(_make_error(
            ERROR_MULTIPLE_ROOT_ELEMENTS,
            "Document has %d root elements, expected exactly 1" % root_element_count,
            count = root_element_count,
        ))

    return (root_nodes, xml_declaration, doctype, errors)

def parse_xml(xml_string, strict = False):
    """
    Parse an XML string into a DOM document.

    Args:
        xml_string: The XML string to parse.
        strict: If True, fail on any parsing errors. If False (default),
                errors are collected in doc.errors but parsing continues.

    Returns:
        A document node representing the parsed XML. The document has an
        'errors' field containing a list of any parsing errors encountered.
    """
    tokens = tokenize(xml_string)
    root_nodes, xml_declaration, doctype, errors = _build_tree(tokens)

    if strict and errors:
        error_messages = [e.message for e in errors]
        fail("XML parsing failed with %d error(s):\n  - %s" % (
            len(errors),
            "\n  - ".join(error_messages),
        ))

    return _make_document_node(
        children = root_nodes,
        xml_declaration = xml_declaration,
        doctype = doctype,
        errors = errors,
    )

def has_errors(doc):
    """
    Check if the document has any parsing errors.

    Args:
        doc: A document node.

    Returns:
        True if the document has errors, False otherwise.
    """
    return len(doc.errors) > 0

def get_errors(doc):
    """
    Get the list of parsing errors from a document.

    Args:
        doc: A document node.

    Returns:
        A list of error structs, each with 'type' and 'message' fields.
    """
    return list(doc.errors)
