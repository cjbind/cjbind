package cjbind_ffi

// Ordinary function documentation.
//
// Example:
//     parse_all_function();
foreign func parse_all_function(): Int32

// ordinary leading member
public const parse_all_kind_PARSE_ALL_LEADING: parse_all_kind = 0

// ordinary trailing member
public const parse_all_kind_PARSE_ALL_TRAILING: parse_all_kind = 1

// < nick=structured >
public const parse_all_kind_PARSE_ALL_STRUCTURED: parse_all_kind = 2

// Member code:
//     parse_all_member();
public const parse_all_kind_PARSE_ALL_CODE: parse_all_kind = 3
public const parse_all_kind_PARSE_ALL_NONE: parse_all_kind = 4

// Ordinary enum documentation.
public type parse_all_kind = UInt32

// Ordinary structure documentation.
@C
public struct parse_all_fields {
    // ordinary leading field
    public var leading: Int32
    // ordinary trailing field
    public var trailing: Int32
    // < private >
    public var structured: Int32
    // Field code:
    //     parse_all_field();
    public var code: Int32
    public var none: Int32
    public init(leading: Int32, trailing: Int32, structured: Int32, code: Int32, none: Int32) {
        this.leading = leading
        this.trailing = trailing
        this.structured = structured
        this.code = code
        this.none = none
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<parse_all_fields>()
        if (size != 20) {
            throw Exception("Size of parse_all_fields is not 20 but ${size} bytes")
        }
        let align = alignOf<parse_all_fields>()
        if (align != 4) {
            throw Exception("Alignment of parse_all_fields is not 4 but ${align} bytes")
        }
}()
