package cjbind_ffi

@C
public struct foo_foo {}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 0) {
            throw Exception("Size of foo_foo is not 0 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 1) {
            throw Exception("Alignment of foo_foo is not 1 but ${align} bytes")
        }
}

public type bar_bar = foo_foo
