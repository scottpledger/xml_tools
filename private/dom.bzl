"DOM-like API for working with parsed XML"

load("//private:parser.bzl", "NODE_CDATA", "NODE_COMMENT", "NODE_DOCUMENT", "NODE_ELEMENT", "NODE_PROCESSING_INSTRUCTION", "NODE_TEXT")

def is_element(node):
    """
    Check if a node is an element node.

    Args:
        node: The node to check.

    Returns:
        True if the node is an element, False otherwise.
    """
    return hasattr(node, "node_type") and node.node_type == NODE_ELEMENT

def is_text(node):
    """
    Check if a node is a text node.

    Args:
        node: The node to check.

    Returns:
        True if the node is a text node, False otherwise.
    """
    return hasattr(node, "node_type") and node.node_type == NODE_TEXT

def is_comment(node):
    """
    Check if a node is a comment node.

    Args:
        node: The node to check.

    Returns:
        True if the node is a comment node, False otherwise.
    """
    return hasattr(node, "node_type") and node.node_type == NODE_COMMENT

def is_cdata(node):
    """
    Check if a node is a CDATA node.

    Args:
        node: The node to check.

    Returns:
        True if the node is a CDATA node, False otherwise.
    """
    return hasattr(node, "node_type") and node.node_type == NODE_CDATA

def is_document(node):
    """
    Check if a node is a document node.

    Args:
        node: The node to check.

    Returns:
        True if the node is a document node, False otherwise.
    """
    return hasattr(node, "node_type") and node.node_type == NODE_DOCUMENT

def is_processing_instruction(node):
    """
    Check if a node is a processing instruction node.

    Args:
        node: The node to check.

    Returns:
        True if the node is a processing instruction, False otherwise.
    """
    return hasattr(node, "node_type") and node.node_type == NODE_PROCESSING_INSTRUCTION

def get_parent(node):
    """
    Get the parent node of a node.

    Args:
        node: The node whose parent to get.

    Returns:
        The parent node, or None if the node has no parent
        (e.g., root element or document-level nodes).
    """
    if hasattr(node, "parent"):
        return node.parent
    return None

def get_tag_name(node):
    """
    Get the tag name of an element node.

    Args:
        node: An element node.

    Returns:
        The tag name string, or None if not an element.
    """
    if not is_element(node):
        return None
    return node.tag_name

def get_attribute(node, name, default = None):
    """
    Get an attribute value from an element node.

    Args:
        node: An element node.
        name: The attribute name to look up.
        default: Default value if attribute is not found.

    Returns:
        The attribute value, or the default if not found.
    """
    if not is_element(node):
        return default
    return node.attributes.get(name, default)

def get_attributes(node):
    """
    Get all attributes of an element node.

    Args:
        node: An element node.

    Returns:
        A dictionary of attribute names to values, or empty dict if not an element.
    """
    if not is_element(node):
        return {}
    return dict(node.attributes)

def has_attribute(node, name):
    """
    Check if an element has a specific attribute.

    Args:
        node: An element node.
        name: The attribute name to check.

    Returns:
        True if the attribute exists, False otherwise.
    """
    if not is_element(node):
        return False
    return name in node.attributes

def get_children(node):
    """
    Get all child nodes of a node.

    Args:
        node: An element or document node.

    Returns:
        A list of child nodes, or empty list if no children.
    """
    if is_element(node) or is_document(node):
        return list(node.children)
    return []

def get_child_elements(node):
    """
    Get all child element nodes of a node (excludes text, comments, etc.).

    Args:
        node: An element or document node.

    Returns:
        A list of child element nodes.
    """
    return [child for child in get_children(node) if is_element(child)]

def get_text(node):
    """
    Get the text content of a node.

    For text nodes, returns the text directly.
    For element nodes, returns concatenated text of all descendant text nodes.
    For CDATA nodes, returns the CDATA content.

    Args:
        node: Any node.

    Returns:
        The text content as a string.
    """
    if is_text(node) or is_cdata(node):
        return node.content

    if is_element(node):
        # Use iterative approach with a stack
        parts = []
        stack = list(node.children)

        # Process in reverse order so we get correct order when popping
        stack = stack[::-1]

        # Limit iterations to prevent infinite loops
        for _ in range(10000):
            if not stack:
                break
            child = stack.pop()
            if is_text(child) or is_cdata(child):
                parts.append(child.content)
            elif is_element(child):
                # Add children in reverse order
                for i in range(len(child.children) - 1, -1, -1):
                    stack.append(child.children[i])

        return "".join(parts)

    return ""

def get_document_element(doc):
    """
    Get the root element of a document.

    Args:
        doc: A document node.

    Returns:
        The root element, or None if the document has no element children.
    """
    if not is_document(doc):
        return None

    for child in doc.children:
        if is_element(child):
            return child
    return None

def _find_elements_matching(node, matcher):
    """
    Find all descendant elements matching a predicate.

    Args:
        node: The starting node (element or document).
        matcher: A function(element) -> bool that returns True for matching elements.

    Returns:
        A list of matching element nodes.
    """
    results = []
    stack = []

    if is_element(node):
        if matcher(node):
            results.append(node)

        # Add children in reverse order for correct document order traversal
        for i in range(len(node.children) - 1, -1, -1):
            stack.append(node.children[i])
    elif is_document(node):
        # Add children in reverse order for correct document order traversal
        for i in range(len(node.children) - 1, -1, -1):
            stack.append(node.children[i])

    # Iterative depth-first search
    for _ in range(100000):
        if not stack:
            break
        current = stack.pop()
        if is_element(current):
            if matcher(current):
                results.append(current)

            # Add children to stack (in reverse for correct order)
            for i in range(len(current.children) - 1, -1, -1):
                stack.append(current.children[i])

    return results

def find_elements_by_tag_name(node, tag_name):
    """
    Find all descendant elements with a specific tag name.

    Args:
        node: The starting node (element or document).
        tag_name: The tag name to search for.

    Returns:
        A list of matching element nodes.
    """
    return _find_elements_matching(node, lambda el: el.tag_name == tag_name)

def find_element_by_tag_name(node, tag_name):
    """
    Find the first descendant element with a specific tag name.

    Args:
        node: The starting node (element or document).
        tag_name: The tag name to search for.

    Returns:
        The first matching element, or None if not found.
    """
    results = find_elements_by_tag_name(node, tag_name)
    if results:
        return results[0]
    return None

def find_elements_by_attribute(node, attr_name, attr_value = None):
    """
    Find all descendant elements with a specific attribute.

    Args:
        node: The starting node (element or document).
        attr_name: The attribute name to search for.
        attr_value: Optional attribute value to match. If None, matches any value.

    Returns:
        A list of matching element nodes.
    """

    def _matches(el):
        if attr_name not in el.attributes:
            return False
        if attr_value == None:
            return True
        return el.attributes[attr_name] == attr_value

    return _find_elements_matching(node, _matches)

def find_element_by_id(node, id_value):
    """
    Find an element by its 'id' attribute.

    Args:
        node: The starting node (element or document).
        id_value: The id value to search for.

    Returns:
        The matching element, or None if not found.
    """
    results = find_elements_by_attribute(node, "id", id_value)
    if results:
        return results[0]
    return None

def get_first_child(node):
    """
    Get the first child node.

    Args:
        node: An element or document node.

    Returns:
        The first child node, or None if no children.
    """
    children = get_children(node)
    if children:
        return children[0]
    return None

def get_last_child(node):
    """
    Get the last child node.

    Args:
        node: An element or document node.

    Returns:
        The last child node, or None if no children.
    """
    children = get_children(node)
    if children:
        return children[-1]
    return None

def get_first_child_element(node):
    """
    Get the first child element node.

    Args:
        node: An element or document node.

    Returns:
        The first child element, or None if no element children.
    """
    elements = get_child_elements(node)
    if elements:
        return elements[0]
    return None

def get_last_child_element(node):
    """
    Get the last child element node.

    Args:
        node: An element or document node.

    Returns:
        The last child element, or None if no element children.
    """
    elements = get_child_elements(node)
    if elements:
        return elements[-1]
    return None

def count_children(node):
    """
    Count the number of child nodes.

    Args:
        node: An element or document node.

    Returns:
        The number of children.
    """
    return len(get_children(node))

def count_child_elements(node):
    """
    Count the number of child element nodes.

    Args:
        node: An element or document node.

    Returns:
        The number of child elements.
    """
    return len(get_child_elements(node))

def walk(node, callback):
    """
    Walk the tree, calling callback for each node.

    Note: In Starlark, this can't modify nodes since they are immutable.
    Use this for collecting information from the tree.

    Args:
        node: The starting node.
        callback: A function(node) to call for each node.
    """
    stack = [node]

    for _ in range(100000):
        if not stack:
            break
        current = stack.pop()
        callback(current)
        children = get_children(current)

        # Add children in reverse order for correct traversal order
        for i in range(len(children) - 1, -1, -1):
            stack.append(children[i])
