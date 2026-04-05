package cjbind_ffi

@C
public struct JNINativeInterface__JNINativeInterface_ {
    public let GetVersion: CFunc<(env: CPointer<Unit>) -> Int32>
    public let __hack: UInt64
    public init(GetVersion: CFunc<(env: CPointer<Unit>) -> Int32>, __hack: UInt64) {
        this.GetVersion = GetVersion
        this.__hack = __hack
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<JNINativeInterface__JNINativeInterface_>()
        if (size != 16) {
            throw Exception("Size of JNINativeInterface__JNINativeInterface_ is not 16 but ${size} bytes")
        }
        let align = alignOf<JNINativeInterface__JNINativeInterface_>()
        if (align != 8) {
            throw Exception("Alignment of JNINativeInterface__JNINativeInterface_ is not 8 but ${align} bytes")
        }
}

foreign func bar(): Unit