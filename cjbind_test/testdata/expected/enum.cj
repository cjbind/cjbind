package cjbind_ffi

public const FOO_A: foo__cjbind_ty_1 = 0
public const FOO_B: foo__cjbind_ty_1 = 1

public type foo__cjbind_ty_1 = UInt32

@C
public struct foo {
    public let member: foo__cjbind_ty_1
    public init(member: foo__cjbind_ty_1) {
        this.member = member
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 4) {
            throw Exception("Size of foo is not 4 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 4) {
            throw Exception("Alignment of foo is not 4 but ${align} bytes")
        }
}

public const Foo_Bar: Foo = 0
public const Foo_Qux: Foo = 1

public type Foo = UInt32

public const Neg_MinusOne: Neg = -1
public const Neg_One: Neg = 1

public type Neg = Int32

public const NoDebug_NoDebug1: NoDebug = 0
public const NoDebug_NoDebug2: NoDebug = 1

public type NoDebug = UInt32

public const Debug_Debug1: Debug = 0
public const Debug_Debug2: Debug = 1

public type Debug = UInt32
