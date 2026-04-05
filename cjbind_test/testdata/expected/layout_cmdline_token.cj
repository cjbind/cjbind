package cjbind_ffi

// Stores a pointer to the ops struct, and the offset: the place to
// write the parsed result in the destination structure.
@C
public struct cmdline_token_hdr_cmdline_token_hdr {
    public let ops: CPointer<cmdline_token_ops_cmdline_token_ops>
    public let offset: UInt32
    public init(ops: CPointer<cmdline_token_ops_cmdline_token_ops>, offset: UInt32) {
        this.ops = ops
        this.offset = offset
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<cmdline_token_hdr_cmdline_token_hdr>()
        if (size != 16) {
            throw Exception("Size of cmdline_token_hdr_cmdline_token_hdr is not 16 but ${size} bytes")
        }
        let align = alignOf<cmdline_token_hdr_cmdline_token_hdr>()
        if (align != 8) {
            throw Exception("Alignment of cmdline_token_hdr_cmdline_token_hdr is not 8 but ${align} bytes")
        }
}

// Stores a pointer to the ops struct, and the offset: the place to
// write the parsed result in the destination structure.
public type cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t = cmdline_token_hdr_cmdline_token_hdr

// A token is defined by this structure.
//
// parse() takes the token as first argument, then the source buffer
// starting at the token we want to parse. The 3rd arg is a pointer
// where we store the parsed data (as binary). It returns the number of
// parsed chars on success and a negative value on error.
//
// complete_get_nb() returns the number of possible values for this
// token if completion is possible. If it is NULL or if it returns 0,
// no completion is possible.
//
// complete_get_elt() copy in dstbuf (the size is specified in the
// parameter) the i-th possible completion for this token.  returns 0
// on success or and a negative value on error.
//
// get_help() fills the dstbuf with the help for the token. It returns
// -1 on error and 0 on success.
@C
public struct cmdline_token_ops_cmdline_token_ops {
    // parse(token ptr, buf, res pts, buf len) *
    public let parse: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>, arg2: CPointer<UInt8>,
        arg3: CPointer<Unit>, arg4: UInt32) -> Int32>
    // return the num of possible choices for this token *
    public let complete_get_nb: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>) -> Int32>
    // return the elt x for this token (token, idx, dstbuf, size) *
    public let complete_get_elt: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>, arg2: Int32,
        arg3: CPointer<UInt8>, arg4: UInt32) -> Int32>
    // get help for this token (token, dstbuf, size) *
    public let get_help: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>, arg2: CPointer<UInt8>,
        arg3: UInt32) -> Int32>
    public init(
        parse: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>, arg2: CPointer<UInt8>, arg3: CPointer<Unit>,
            arg4: UInt32) -> Int32>,
        complete_get_nb: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>) -> Int32>,
        complete_get_elt: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>, arg2: Int32, arg3: CPointer<UInt8>,
            arg4: UInt32) -> Int32>,
        get_help: CFunc<(arg1: CPointer<cmdline_parse_token_hdr_t_cmdline_parse_token_hdr_t>, arg2: CPointer<UInt8>,
            arg3: UInt32) -> Int32>) {
        this.parse = parse
        this.complete_get_nb = complete_get_nb
        this.complete_get_elt = complete_get_elt
        this.get_help = get_help
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<cmdline_token_ops_cmdline_token_ops>()
        if (size != 32) {
            throw Exception("Size of cmdline_token_ops_cmdline_token_ops is not 32 but ${size} bytes")
        }
        let align = alignOf<cmdline_token_ops_cmdline_token_ops>()
        if (align != 8) {
            throw Exception("Alignment of cmdline_token_ops_cmdline_token_ops is not 8 but ${align} bytes")
        }
}

public const cmdline_numtype_UINT8: cmdline_numtype_cmdline_numtype = 0
public const cmdline_numtype_UINT16: cmdline_numtype_cmdline_numtype = 1
public const cmdline_numtype_UINT32: cmdline_numtype_cmdline_numtype = 2
public const cmdline_numtype_UINT64: cmdline_numtype_cmdline_numtype = 3
public const cmdline_numtype_INT8: cmdline_numtype_cmdline_numtype = 4
public const cmdline_numtype_INT16: cmdline_numtype_cmdline_numtype = 5
public const cmdline_numtype_INT32: cmdline_numtype_cmdline_numtype = 6
public const cmdline_numtype_INT64: cmdline_numtype_cmdline_numtype = 7

public type cmdline_numtype_cmdline_numtype = UInt32

@C
public struct cmdline_token_num_data_cmdline_token_num_data {
    public let type_: cmdline_numtype_cmdline_numtype
    public init(type_: cmdline_numtype_cmdline_numtype) {
        this.type_ = type_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<cmdline_token_num_data_cmdline_token_num_data>()
        if (size != 4) {
            throw Exception("Size of cmdline_token_num_data_cmdline_token_num_data is not 4 but ${size} bytes")
        }
        let align = alignOf<cmdline_token_num_data_cmdline_token_num_data>()
        if (align != 4) {
            throw Exception("Alignment of cmdline_token_num_data_cmdline_token_num_data is not 4 but ${align} bytes")
        }
}

@C
public struct cmdline_token_num_cmdline_token_num {
    public let hdr: cmdline_token_hdr_cmdline_token_hdr
    public let num_data: cmdline_token_num_data_cmdline_token_num_data
    public init(hdr: cmdline_token_hdr_cmdline_token_hdr, num_data: cmdline_token_num_data_cmdline_token_num_data) {
        this.hdr = hdr
        this.num_data = num_data
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<cmdline_token_num_cmdline_token_num>()
        if (size != 24) {
            throw Exception("Size of cmdline_token_num_cmdline_token_num is not 24 but ${size} bytes")
        }
        let align = alignOf<cmdline_token_num_cmdline_token_num>()
        if (align != 8) {
            throw Exception("Alignment of cmdline_token_num_cmdline_token_num is not 8 but ${align} bytes")
        }
}

public type cmdline_parse_token_num_t_cmdline_parse_token_num_t = cmdline_token_num_cmdline_token_num