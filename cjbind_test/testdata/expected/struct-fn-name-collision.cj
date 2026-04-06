package cjbind_ffi

@C
public struct foo_foo {
    init() {
        throw Exception("type should not be inited")
    }
}

foreign func foo(): Int32
