# xml_tools

A pure Starlark XML parser for Bazel. Parse XML strings and navigate the resulting document using a DOM-like API.

## Features

- Pure Starlark implementation - no external dependencies needed at runtime
- DOM-like API for navigating and querying parsed XML
- Supports XML declarations, comments, CDATA sections, and processing instructions
- Entity decoding (`&lt;`, `&gt;`, `&amp;`, `&quot;`, `&apos;`)
- Serialize documents back to XML strings
- Error tracking with optional strict mode

## Installation

### With bzlmod (MODULE.bazel)

Add to your `MODULE.bazel`:

```starlark
bazel_dep(name = "xml_tools", version = "<version>")
```

### With WORKSPACE

Add to your `WORKSPACE` file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "xml_tools",
    sha256 = "<sha256>",
    strip_prefix = "xml_tools-<version>",
    url = "https://github.com/scottpledger/xml_tools/releases/download/v<version>/xml_tools-v<version>.tar.gz",
)
```

## Usage

### Basic Parsing

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

def _my_rule_impl(ctx):
    xml_content = '''<?xml version="1.0"?>
    <config>
        <setting name="debug">true</setting>
        <setting name="timeout">30</setting>
    </config>
    '''

    doc = xml.parse(xml_content)
    root = xml.get_document_element(doc)
    print("Root element:", xml.get_tag_name(root))  # "config"
```

### Navigating the DOM

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

doc = xml.parse("<root><a>1</a><b>2</b><c>3</c></root>")
root = xml.get_document_element(doc)

# Get all child elements
for child in xml.get_child_elements(root):
    print(xml.get_tag_name(child), "=", xml.get_text(child))
# Output: a = 1, b = 2, c = 3

# Navigate to parent
first_child = xml.get_first_child_element(root)
parent = xml.get_parent(first_child)
print(xml.get_tag_name(parent))  # "root"

# Root element has no parent
print(xml.get_parent(root))  # None
```

### Working with Attributes

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

doc = xml.parse('<item id="123" type="widget" enabled="true"/>')
root = xml.get_document_element(doc)

# Get a specific attribute
id = xml.get_attribute(root, "id")  # "123"

# Get with default value
color = xml.get_attribute(root, "color", "blue")  # "blue" (default)

# Check if attribute exists
if xml.has_attribute(root, "enabled"):
    print("Item is enabled")

# Get all attributes as a dict
attrs = xml.get_attributes(root)  # {"id": "123", "type": "widget", "enabled": "true"}
```

### Finding Elements

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

xml_str = '''
<root>
    <item id="first">One</item>
    <item id="second">Two</item>
    <nested>
        <item id="third">Three</item>
    </nested>
</root>
'''
doc = xml.parse(xml_str)

# Find all elements with a specific tag name
items = xml.find_elements_by_tag_name(doc, "item")  # Returns 3 items

# Find first element with a tag name
first_item = xml.find_element_by_tag_name(doc, "item")
print(xml.get_text(first_item))  # "One"

# Find element by id
second = xml.find_element_by_id(doc, "second")
print(xml.get_text(second))  # "Two"

# Find elements by attribute
enabled_items = xml.find_elements_by_attribute(doc, "enabled", "true")
```

### Type Checking

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

doc = xml.parse("<root>text<!--comment--></root>")
root = xml.get_document_element(doc)

for child in xml.get_children(root):
    if xml.is_text(child):
        print("Text node")
    elif xml.is_comment(child):
        print("Comment node")
    elif xml.is_element(child):
        print("Element node")
```

### Error Handling

The parser tracks errors encountered during parsing. By default, it operates in lenient mode, continuing to parse even when errors are found.

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

# Lenient mode (default) - errors are tracked but parsing continues
doc = xml.parse("<root><a></b></root>")  # Mismatched tags

# Check for errors
if xml.has_errors(doc):
    for error in xml.get_errors(doc):
        print("Error:", error.message)
        print("Type:", error.type)

# Errors are also accessible directly on the document
for error in doc.errors:
    print(error.type, "-", error.message)
```

#### Strict Mode

Use `strict=True` to fail immediately on any parsing error:

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

# Strict mode - fails on first error
doc = xml.parse("<root><a></b></root>", strict = True)
# This will call fail() with error details
```

#### Error Types

The following error types are detected:

| Error Type             | Constant                           | Description                              |
| ---------------------- | ---------------------------------- | ---------------------------------------- |
| Mismatched tag         | `xml.ERROR_MISMATCHED_TAG`         | Closing tag doesn't match opening tag    |
| Unclosed tag           | `xml.ERROR_UNCLOSED_TAG`           | Tag was never closed                     |
| Unexpected end tag     | `xml.ERROR_UNEXPECTED_END_TAG`     | Closing tag with no matching opener      |
| Multiple root elements | `xml.ERROR_MULTIPLE_ROOT_ELEMENTS` | Document has more than one root element  |
| Text outside root      | `xml.ERROR_TEXT_OUTSIDE_ROOT`      | Non-whitespace text outside root element |

#### Error Object Fields

Each error object has the following fields:

- `type` - The error type constant
- `message` - Human-readable error description
- Additional fields depending on error type (e.g., `expected`, `found`, `tag_name`, `count`)

### Serialization

```starlark
load("@xml_tools//xml:defs.bzl", "xml")

doc = xml.parse('<root><child attr="value">text</child></root>')

# Serialize to string (nested elements are indented by default)
xml_string = xml.to_string(doc)

# Use custom indentation (4 spaces instead of default 2)
xml_string = xml.to_string(doc, indent_str = "    ")

# Use tabs for indentation
xml_string = xml.to_string(doc, indent_str = "\t")

# Compact output (no indentation or extra whitespace)
xml_string = xml.to_string(doc, pretty = False)
```

## API Reference

All functions are accessed via the `xml` struct:

```starlark
load("@xml_tools//xml:defs.bzl", "xml")
```

### Parsing

| Function                              | Description                                    |
| ------------------------------------- | ---------------------------------------------- |
| `xml.parse(xml_string, strict=False)` | Parse an XML string and return a document node |

### Error Handling

| Function              | Description                              |
| --------------------- | ---------------------------------------- |
| `xml.has_errors(doc)` | Check if document has any parsing errors |
| `xml.get_errors(doc)` | Get list of error objects from document  |

### Type Checking

| Function                              | Description                               |
| ------------------------------------- | ----------------------------------------- |
| `xml.is_document(node)`               | Check if node is a document               |
| `xml.is_element(node)`                | Check if node is an element               |
| `xml.is_text(node)`                   | Check if node is a text node              |
| `xml.is_comment(node)`                | Check if node is a comment                |
| `xml.is_cdata(node)`                  | Check if node is a CDATA section          |
| `xml.is_processing_instruction(node)` | Check if node is a processing instruction |

### Element Access

| Function                                      | Description                    |
| --------------------------------------------- | ------------------------------ |
| `xml.get_tag_name(node)`                      | Get the tag name of an element |
| `xml.get_attribute(node, name, default=None)` | Get an attribute value         |
| `xml.get_attributes(node)`                    | Get all attributes as a dict   |
| `xml.has_attribute(node, name)`               | Check if attribute exists      |

### Navigation

| Function                            | Description                         |
| ----------------------------------- | ----------------------------------- |
| `xml.get_document_element(doc)`     | Get the root element of a document  |
| `xml.get_parent(node)`              | Get the parent node (None for root) |
| `xml.get_children(node)`            | Get all child nodes                 |
| `xml.get_child_elements(node)`      | Get child element nodes only        |
| `xml.get_first_child(node)`         | Get the first child node            |
| `xml.get_last_child(node)`          | Get the last child node             |
| `xml.get_first_child_element(node)` | Get the first child element         |
| `xml.get_last_child_element(node)`  | Get the last child element          |

### Content

| Function             | Description                                  |
| -------------------- | -------------------------------------------- |
| `xml.get_text(node)` | Get text content (concatenated for elements) |

### Search

| Function                                                           | Description                               |
| ------------------------------------------------------------------ | ----------------------------------------- |
| `xml.find_elements_by_tag_name(node, tag_name)`                    | Find all descendant elements by tag name  |
| `xml.find_element_by_tag_name(node, tag_name)`                     | Find first descendant element by tag name |
| `xml.find_elements_by_attribute(node, attr_name, attr_value=None)` | Find elements by attribute                |
| `xml.find_element_by_id(node, id_value)`                           | Find element by id attribute              |

### Utilities

| Function                                                      | Description                                                          |
| ------------------------------------------------------------- | -------------------------------------------------------------------- |
| `xml.count_children(node)`                                    | Count child nodes                                                    |
| `xml.count_child_elements(node)`                              | Count child elements                                                 |
| `xml.walk(node, callback)`                                    | Walk tree calling callback for each node                             |
| `xml.to_string(node, indent=0, indent_str="  ", pretty=True)` | Serialize node to XML string. Use `pretty=False` for compact output. |

### Error Type Constants

| Constant                           | Description                              |
| ---------------------------------- | ---------------------------------------- |
| `xml.ERROR_MISMATCHED_TAG`         | Closing tag doesn't match opening tag    |
| `xml.ERROR_UNCLOSED_TAG`           | Tag was never closed                     |
| `xml.ERROR_UNEXPECTED_END_TAG`     | Closing tag with no matching opener      |
| `xml.ERROR_MULTIPLE_ROOT_ELEMENTS` | Document has more than one root element  |
| `xml.ERROR_TEXT_OUTSIDE_ROOT`      | Non-whitespace text outside root element |

## Limitations

- This is a basic XML parser suitable for configuration files and simple documents
- Does not validate against DTD or XSD schemas
- Does not support XML namespaces (prefixed names work but aren't namespace-aware)
- Entity references beyond the built-in five are not expanded
- Large documents may hit Starlark memory/computation limits

## License

Apache 2.0 - see [LICENSE](LICENSE)
