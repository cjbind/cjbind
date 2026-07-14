package cjbind_ffi

@C
public struct MyType_MyType {
    public func toString(): String {
        var output = "MyType_MyType {"
        output += " }"
        return output
    }
    init() {
        throw Exception("type should not be inited")
    }
}

public type MyTypeT_MyTypeT = MyType_MyType
