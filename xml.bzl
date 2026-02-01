"Public API for xml.bzl - XML parsing and building utilities for Starlark/Bazel"

load(
    "//private:builder.bzl",
    _cdata = "cdata",
    _comment = "comment",
    _document = "document",
    _element = "element",
    _processing_instruction = "processing_instruction",
    _text = "text",
)
load(
    "//private:dom.bzl",
    _count_child_elements = "count_child_elements",
    _count_children = "count_children",
    _find_element_by_id = "find_element_by_id",
    _find_element_by_tag_name = "find_element_by_tag_name",
    _find_elements_by_attribute = "find_elements_by_attribute",
    _find_elements_by_tag_name = "find_elements_by_tag_name",
    _get_attribute = "get_attribute",
    _get_attributes = "get_attributes",
    _get_child_elements = "get_child_elements",
    _get_children = "get_children",
    _get_document_element = "get_document_element",
    _get_first_child = "get_first_child",
    _get_first_child_element = "get_first_child_element",
    _get_last_child = "get_last_child",
    _get_last_child_element = "get_last_child_element",
    _get_parent = "get_parent",
    _get_tag_name = "get_tag_name",
    _get_text = "get_text",
    _has_attribute = "has_attribute",
    _is_cdata = "is_cdata",
    _is_comment = "is_comment",
    _is_document = "is_document",
    _is_element = "is_element",
    _is_processing_instruction = "is_processing_instruction",
    _is_text = "is_text",
    _walk = "walk",
)
load(
    "//private:parser.bzl",
    _ERROR_MISMATCHED_TAG = "ERROR_MISMATCHED_TAG",
    _ERROR_MULTIPLE_ROOT_ELEMENTS = "ERROR_MULTIPLE_ROOT_ELEMENTS",
    _ERROR_TEXT_OUTSIDE_ROOT = "ERROR_TEXT_OUTSIDE_ROOT",
    _ERROR_UNCLOSED_TAG = "ERROR_UNCLOSED_TAG",
    _ERROR_UNEXPECTED_END_TAG = "ERROR_UNEXPECTED_END_TAG",
    _get_errors = "get_errors",
    _has_errors = "has_errors",
    _parse_xml = "parse_xml",
)
load(
    "//private:serializer.bzl",
    _to_string = "to_string",
)

xml = struct(
    # Parsing
    parse = _parse_xml,

    # Error handling
    has_errors = _has_errors,
    get_errors = _get_errors,

    # Error type constants
    ERROR_MISMATCHED_TAG = _ERROR_MISMATCHED_TAG,
    ERROR_UNCLOSED_TAG = _ERROR_UNCLOSED_TAG,
    ERROR_UNEXPECTED_END_TAG = _ERROR_UNEXPECTED_END_TAG,
    ERROR_MULTIPLE_ROOT_ELEMENTS = _ERROR_MULTIPLE_ROOT_ELEMENTS,
    ERROR_TEXT_OUTSIDE_ROOT = _ERROR_TEXT_OUTSIDE_ROOT,

    # Type checking functions
    is_element = _is_element,
    is_text = _is_text,
    is_comment = _is_comment,
    is_cdata = _is_cdata,
    is_document = _is_document,
    is_processing_instruction = _is_processing_instruction,

    # Element access functions
    get_tag_name = _get_tag_name,
    get_attribute = _get_attribute,
    get_attributes = _get_attributes,
    has_attribute = _has_attribute,

    # Navigation functions
    get_children = _get_children,
    get_child_elements = _get_child_elements,
    get_first_child = _get_first_child,
    get_last_child = _get_last_child,
    get_first_child_element = _get_first_child_element,
    get_last_child_element = _get_last_child_element,
    get_parent = _get_parent,
    get_document_element = _get_document_element,

    # Content functions
    get_text = _get_text,

    # Search functions
    find_elements_by_tag_name = _find_elements_by_tag_name,
    find_element_by_tag_name = _find_element_by_tag_name,
    find_elements_by_attribute = _find_elements_by_attribute,
    find_element_by_id = _find_element_by_id,

    # Utility functions
    count_children = _count_children,
    count_child_elements = _count_child_elements,
    walk = _walk,
    to_string = _to_string,

    # Builder functions (for constructing XML programmatically)
    element = _element,
    text = _text,
    comment = _comment,
    cdata = _cdata,
    document = _document,
    processing_instruction = _processing_instruction,
)
