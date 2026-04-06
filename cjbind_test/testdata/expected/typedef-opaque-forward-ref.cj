package cjbind_ffi

@C
public struct MyType_MyType {
    init() {
        throw Exception("type should not be inited")
    }
}

public type MyTypeT_MyTypeT = MyType_MyType
