package cjbind_ffi

@C
public struct zoidberg_Foo {
    public let c: UInt8
    public init(c: UInt8) {
        this.c = c
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<zoidberg_Foo>()
        if (size != 1) {
            throw Exception("Size of zoidberg_Foo is not 1 but ${size} bytes")
        }
        let align = alignOf<zoidberg_Foo>()
        if (align != 1) {
            throw Exception("Alignment of zoidberg_Foo is not 1 but ${align} bytes")
        }
}

@C
public struct zoidberg_Bar {
    public let i: Int32
    public init(i: Int32) {
        this.i = i
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<zoidberg_Bar>()
        if (size != 4) {
            throw Exception("Size of zoidberg_Bar is not 4 but ${size} bytes")
        }
        let align = alignOf<zoidberg_Bar>()
        if (align != 4) {
            throw Exception("Alignment of zoidberg_Bar is not 4 but ${align} bytes")
        }
}

@C
public struct zoidberg_ContainsInstantiation {
    public let not_opaque: zoidberg_Template_open0_zoidberg_Foo_close0
    public init(not_opaque: zoidberg_Template_open0_zoidberg_Foo_close0) {
        this.not_opaque = not_opaque
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<zoidberg_ContainsInstantiation>()
        if (size != 1) {
            throw Exception("Size of zoidberg_ContainsInstantiation is not 1 but ${size} bytes")
        }
        let align = alignOf<zoidberg_ContainsInstantiation>()
        if (align != 1) {
            throw Exception("Alignment of zoidberg_ContainsInstantiation is not 1 but ${align} bytes")
        }
}

@C
public struct zoidberg_ContainsOpaqueInstantiation {
    public let opaque: UInt32
    public init(opaque: UInt32) {
        this.opaque = opaque
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<zoidberg_ContainsOpaqueInstantiation>()
        if (size != 4) {
            throw Exception("Size of zoidberg_ContainsOpaqueInstantiation is not 4 but ${size} bytes")
        }
        let align = alignOf<zoidberg_ContainsOpaqueInstantiation>()
        if (align != 4) {
            throw Exception("Alignment of zoidberg_ContainsOpaqueInstantiation is not 4 but ${align} bytes")
        }
}

@C
public struct zoidberg_Template_open0_zoidberg_Foo_close0 {
    public let member: zoidberg_Foo
    public init(member: zoidberg_Foo) {
        this.member = member
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<zoidberg_Template_open0_zoidberg_Foo_close0>()
        if (size != 1) {
            throw Exception("Size of zoidberg_Template_open0_zoidberg_Foo_close0 is not 1 but ${size} bytes")
        }
        let align = alignOf<zoidberg_Template_open0_zoidberg_Foo_close0>()
        if (align != 1) {
            throw Exception("Alignment of zoidberg_Template_open0_zoidberg_Foo_close0 is not 1 but ${align} bytes")
        }
}
