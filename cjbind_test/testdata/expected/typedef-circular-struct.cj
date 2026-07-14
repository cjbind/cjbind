package cjbind_ffi

@C
public struct foo {}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 0) {
            throw Exception("Size of foo is not 0 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 1) {
            throw Exception("Alignment of foo is not 1 but ${align} bytes")
        }
}

public type bar = foo
