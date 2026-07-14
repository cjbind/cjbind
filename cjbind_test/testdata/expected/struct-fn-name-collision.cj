package cjbind_ffi

@C
public struct foo_foo {
    public func toString(): String {
        var output = "foo_foo {"
        output += " }"
        return output
    }
    init() {
        throw Exception("type should not be inited")
    }
}

foreign func foo(): Int32
