package cjbind_ffi

@C
public struct max_align_t_max_align_t {
    public let __clang_max_align_nonce1: Int64
    public let __clang_max_align_nonce2: Int64
    public init(__clang_max_align_nonce1: Int64, __clang_max_align_nonce2: Int64) {
        this.__clang_max_align_nonce1 = __clang_max_align_nonce1
        this.__clang_max_align_nonce2 = __clang_max_align_nonce2
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<max_align_t_max_align_t>()
        if (size != 32) {
            throw Exception("Size of max_align_t_max_align_t is not 32 but ${size} bytes")
        }
        let align = alignOf<max_align_t_max_align_t>()
        if (align != 16) {
            throw Exception("Alignment of max_align_t_max_align_t is not 16 but ${align} bytes")
        }
}