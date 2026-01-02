package cjbind.codegen

enum Error {
    NoLayoutForOpaqueBlob |
    UnsupportedAbi(String) |
    // type name, type size, pointer size
    InvalidPointerSize(String, UIntNative, UIntNative) |
    Unsupported(String)
}