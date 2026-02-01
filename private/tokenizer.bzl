"XML tokenizer for parsing XML strings into tokens"

# Token types
TOKEN_START_TAG = "start_tag"
TOKEN_END_TAG = "end_tag"
TOKEN_SELF_CLOSING = "self_closing"
TOKEN_TEXT = "text"
TOKEN_COMMENT = "comment"
TOKEN_CDATA = "cdata"
TOKEN_PI = "processing_instruction"
TOKEN_DOCTYPE = "doctype"
TOKEN_XML_DECL = "xml_declaration"

def _is_whitespace(char):
    """Check if character is whitespace."""
    return char in [" ", "\t", "\n", "\r"]

def _is_name_start_char(char):
    """Check if character can start an XML name."""
    if not char:
        return False

    # Simplified: letters, underscore, colon
    return char.isalpha() or char == "_" or char == ":"

def _is_name_char(char):
    """Check if character can be part of an XML name."""
    if not char:
        return False
    return char.isalpha() or char.isdigit() or char in ["_", ":", "-", "."]

def _skip_whitespace(xml, pos):
    """Skip whitespace characters and return new position."""
    for _ in range(len(xml)):
        if pos >= len(xml) or not _is_whitespace(xml[pos]):
            break
        pos += 1
    return pos

def _parse_name(xml, pos):
    """Parse an XML name starting at pos. Returns (name, new_pos) or (None, pos) on failure."""
    if pos >= len(xml) or not _is_name_start_char(xml[pos]):
        return (None, pos)

    start = pos
    pos += 1
    for _ in range(len(xml)):
        if pos >= len(xml) or not _is_name_char(xml[pos]):
            break
        pos += 1

    return (xml[start:pos], pos)

def _parse_attribute_value(xml, pos):
    """Parse an attribute value (quoted string). Returns (value, new_pos) or (None, pos) on failure."""
    if pos >= len(xml):
        return (None, pos)

    quote = xml[pos]
    if quote != '"' and quote != "'":
        return (None, pos)

    pos += 1
    start = pos

    for _ in range(len(xml)):
        if pos >= len(xml) or xml[pos] == quote:
            break
        pos += 1

    if pos >= len(xml):
        return (None, start - 1)  # Unclosed quote

    value = xml[start:pos]
    return (value, pos + 1)

def _parse_attributes(xml, pos):
    """Parse attributes until '>' or '/>'. Returns (attrs_dict, new_pos, is_self_closing)."""
    attrs = {}

    for _ in range(len(xml)):
        if pos >= len(xml):
            break

        pos = _skip_whitespace(xml, pos)

        if pos >= len(xml):
            break

        # Check for end of tag
        if xml[pos] == ">":
            return (attrs, pos + 1, False)

        if pos + 1 < len(xml) and xml[pos:pos + 2] == "/>":
            return (attrs, pos + 2, True)

        # Parse attribute name
        name, pos = _parse_name(xml, pos)
        if not name:
            # Skip unknown character
            pos += 1
            continue

        pos = _skip_whitespace(xml, pos)

        # Expect '='
        if pos >= len(xml) or xml[pos] != "=":
            # Attribute without value (like HTML boolean attrs) - set to empty string
            attrs[name] = ""
            continue

        pos += 1  # Skip '='
        pos = _skip_whitespace(xml, pos)

        # Parse attribute value
        value, pos = _parse_attribute_value(xml, pos)
        if value == None:
            value = ""

        attrs[name] = _decode_entities(value)

    return (attrs, pos, False)

def _decode_entities(text):
    """Decode XML entities in text.

    Note: &amp; must be decoded LAST to prevent double-decoding.
    For example, &amp;apos; should become &apos; (literal), not '.
    """
    result = text
    result = result.replace("&lt;", "<")
    result = result.replace("&gt;", ">")
    result = result.replace("&apos;", "'")
    result = result.replace("&quot;", '"')
    result = result.replace("&amp;", "&")  # Must be last!
    return result

def _parse_comment(xml, pos):
    """Parse a comment starting at pos (after '<!--'). Returns (comment_text, new_pos)."""
    start = pos
    for _ in range(len(xml)):
        if pos + 2 >= len(xml):
            break
        if xml[pos:pos + 3] == "-->":
            return (xml[start:pos], pos + 3)
        pos += 1
    return (xml[start:], len(xml))

def _parse_cdata(xml, pos):
    """Parse CDATA section starting at pos (after '<![CDATA['). Returns (cdata_text, new_pos)."""
    start = pos
    for _ in range(len(xml)):
        if pos + 2 >= len(xml):
            break
        if xml[pos:pos + 3] == "]]>":
            return (xml[start:pos], pos + 3)
        pos += 1
    return (xml[start:], len(xml))

def _parse_processing_instruction(xml, pos):
    """Parse processing instruction starting at pos (after '<?'). Returns (target, data, new_pos)."""
    target, pos = _parse_name(xml, pos)
    if not target:
        target = ""

    pos = _skip_whitespace(xml, pos)
    start = pos

    for _ in range(len(xml)):
        if pos + 1 >= len(xml):
            break
        if xml[pos:pos + 2] == "?>":
            return (target, xml[start:pos].strip(), pos + 2)
        pos += 1

    return (target, xml[start:].strip(), len(xml))

def _parse_doctype(xml, pos):
    """Parse DOCTYPE declaration. Returns (doctype_content, new_pos)."""
    start = pos
    depth = 1

    for _ in range(len(xml)):
        if pos >= len(xml) or depth <= 0:
            break
        if xml[pos] == "<":
            depth += 1
        elif xml[pos] == ">":
            depth -= 1
        pos += 1

    return (xml[start:pos - 1].strip() if pos > start else "", pos)

def _make_token(token_type, **kwargs):
    """Create a token struct."""
    return struct(
        type = token_type,
        **kwargs
    )

def _skip_to_char(xml, pos, char):
    """Skip forward until we find char. Returns new position."""
    for _ in range(len(xml)):
        if pos >= len(xml) or xml[pos] == char:
            break
        pos += 1
    return pos

def tokenize(xml):
    """
    Tokenize an XML string into a list of tokens.

    Args:
        xml: The XML string to tokenize.

    Returns:
        A list of token structs, each with a 'type' field and type-specific fields.
    """
    tokens = []
    pos = 0
    max_iterations = len(xml) + 1

    for _ in range(max_iterations):
        if pos >= len(xml):
            break

        if xml[pos] == "<":
            # Check what kind of tag this is
            if pos + 1 >= len(xml):
                break

            next_char = xml[pos + 1]

            if next_char == "/":
                # End tag
                pos += 2
                name, pos = _parse_name(xml, pos)
                if name:
                    # Skip to closing >
                    pos = _skip_to_char(xml, pos, ">")
                    pos += 1
                    tokens.append(_make_token(TOKEN_END_TAG, name = name))

            elif next_char == "!":
                # Comment, CDATA, or DOCTYPE
                if pos + 3 < len(xml) and xml[pos:pos + 4] == "<!--":
                    pos += 4
                    comment, pos = _parse_comment(xml, pos)
                    tokens.append(_make_token(TOKEN_COMMENT, content = comment))

                elif pos + 8 < len(xml) and xml[pos:pos + 9] == "<![CDATA[":
                    pos += 9
                    cdata, pos = _parse_cdata(xml, pos)
                    tokens.append(_make_token(TOKEN_CDATA, content = cdata))

                elif pos + 8 < len(xml) and xml[pos:pos + 9].upper() == "<!DOCTYPE":
                    pos += 9
                    doctype, pos = _parse_doctype(xml, pos)
                    tokens.append(_make_token(TOKEN_DOCTYPE, content = doctype))

                else:
                    # Unknown, skip
                    pos += 1

            elif next_char == "?":
                # Processing instruction or XML declaration
                pos += 2
                target, data, pos = _parse_processing_instruction(xml, pos)

                if target.lower() == "xml":
                    # Parse XML declaration attributes
                    # Simple parsing of version, encoding, standalone
                    tokens.append(_make_token(TOKEN_XML_DECL, content = data))
                else:
                    tokens.append(_make_token(TOKEN_PI, target = target, content = data))

            else:
                # Start tag
                pos += 1
                name, pos = _parse_name(xml, pos)
                if name:
                    attrs, pos, is_self_closing = _parse_attributes(xml, pos)
                    if is_self_closing:
                        tokens.append(_make_token(TOKEN_SELF_CLOSING, name = name, attributes = attrs))
                    else:
                        tokens.append(_make_token(TOKEN_START_TAG, name = name, attributes = attrs))
                else:
                    # Invalid tag, skip
                    pos += 1

        else:
            # Text content
            start = pos
            pos = _skip_to_char(xml, pos, "<")

            text = xml[start:pos]

            # Only add non-empty text (after trimming pure whitespace at element boundaries)
            if text.strip():
                tokens.append(_make_token(TOKEN_TEXT, content = _decode_entities(text)))
            elif text and not text.strip():
                # Preserve whitespace-only text for formatting
                tokens.append(_make_token(TOKEN_TEXT, content = text))

    return tokens
