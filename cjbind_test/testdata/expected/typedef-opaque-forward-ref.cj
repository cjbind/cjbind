package cjbind_ffi

@C
public struct MyType {
    init() {
        throw Exception("type should not be inited")
    }
}

public type MyTypeT = MyType
