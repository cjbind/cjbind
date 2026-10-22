package cjbind_ffi

// cjbind-options: --default-alias-style new_type
foreign func unnamed_first(arg2: Int32, arg1: Int32): Unit

foreign func unnamed_last(arg1: Int32, arg2: Int32): Unit

foreign func keyword_collision(type_: Int32, type__2: Int32, type__1: Int32): Unit

foreign func identity(identity_1: Int32): Int32

@C
public struct Strong {
    public var rawValue: Int32

    public init(rawValue!: Int32) {
        this.rawValue = rawValue
    }
}

foreign func alias_collision(arg1: Int32, arg2: Int32): Int32

public unsafe func alias_collision_cjbindwrapper(arg1: Strong, arg2: Strong): Strong {
    return Strong(rawValue: alias_collision(arg1.rawValue, arg2.rawValue))
}

foreign func alias_shadow(alias_shadow_1: Int32): Int32

public unsafe func alias_shadow_cjbindwrapper(alias_shadow_1: Strong): Strong {
    return Strong(rawValue: alias_shadow(alias_shadow_1.rawValue))
}

@C
public struct Callback {
    public var rawValue: CFunc<(arg1: Int32, arg2: Int32) -> Int32>

    public init(rawValue!: CFunc<(arg1: Int32, arg2: Int32) -> Int32>) {
        this.rawValue = rawValue
    }
}

@C
public struct Callbacks {
    public var callback: CFunc<(arg1: Int32, arg2: Int32) -> Int32>
    public init(callback: CFunc<(arg1: Int32, arg2: Int32) -> Int32>) {
        this.callback = callback
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Callbacks>()
        if (size != 8) {
            throw Exception("Size of Callbacks is not 8 but ${size} bytes")
        }
        let align = alignOf<Callbacks>()
        if (align != 8) {
            throw Exception("Alignment of Callbacks is not 8 but ${align} bytes")
        }
}
