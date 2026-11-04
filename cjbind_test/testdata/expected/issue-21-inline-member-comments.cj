package cjbind_ffi

// unmarked line documentation
public const issue_21_level_ISSUE_21_NONE: issue_21_level = 0

// marked line documentation
public const issue_21_level_ISSUE_21_FATAL: issue_21_level = 1

// unmarked block documentation
public const issue_21_level_ISSUE_21_ERROR: issue_21_level = 2

// marked block documentation
public const issue_21_level_ISSUE_21_WARN: issue_21_level = 3

// ordinary line comment
public const issue_21_level_ISSUE_21_INFO: issue_21_level = 4

// ordinary block comment
public const issue_21_level_ISSUE_21_DEBUG: issue_21_level = 5

// leading line documentation
public const issue_21_level_ISSUE_21_TRACE: issue_21_level = 6
public const issue_21_level_ISSUE_21_UNDOCUMENTED: issue_21_level = 7

// malformed marked line documentation
public const issue_21_level_ISSUE_21_MALFORMED: issue_21_level = 8

// final unmarked line documentation
public const issue_21_level_ISSUE_21_LAST: issue_21_level = 9

// Mixed inline member comment styles.
public type issue_21_level = UInt32

// Fields with mixed inline comment styles.
@C
public struct issue_21_fields {
    // field unmarked line documentation
    public var line_doc: Int32
    // field unmarked block documentation
    public var block_doc: Int32
    // field ordinary line comment
    public var ordinary_line: Int32
    // field ordinary block comment
    public var ordinary_block: Int32
    // field leading documentation
    public var leading: Int32
    public var undocumented: Int32
    // field malformed marked line documentation
    public var malformed: Int32
    // field final unmarked line documentation
    public var last: Int32
    public init(line_doc: Int32, block_doc: Int32, ordinary_line: Int32, ordinary_block: Int32, leading: Int32,
        undocumented: Int32, malformed: Int32, last: Int32) {
        this.line_doc = line_doc
        this.block_doc = block_doc
        this.ordinary_line = ordinary_line
        this.ordinary_block = ordinary_block
        this.leading = leading
        this.undocumented = undocumented
        this.malformed = malformed
        this.last = last
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<issue_21_fields>()
        if (size != 32) {
            throw Exception("Size of issue_21_fields is not 32 but ${size} bytes")
        }
        let align = alignOf<issue_21_fields>()
        if (align != 4) {
            throw Exception("Alignment of issue_21_fields is not 4 but ${align} bytes")
        }
}()
