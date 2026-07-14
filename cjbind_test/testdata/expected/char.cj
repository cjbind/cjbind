package cjbind_ffi

public type Char = UInt8

public type SChar = Int8

public type UChar = UInt8

@C
public struct Test {
    public let ch: UInt8
    public let u: UInt8
    public let d: Int8
    public let cch: UInt8
    public let cu: UInt8
    public let cd: Int8
    public let Cch: Char
    public let Cu: UChar
    public let Cd: SChar
    public let Ccch: Char
    public let Ccu: UChar
    public let Ccd: SChar
    public init(ch: UInt8, u: UInt8, d: Int8, cch: UInt8, cu: UInt8, cd: Int8, Cch: Char, Cu: UChar, Cd: SChar,
        Ccch: Char, Ccu: UChar, Ccd: SChar) {
        this.ch = ch
        this.u = u
        this.d = d
        this.cch = cch
        this.cu = cu
        this.cd = cd
        this.Cch = Cch
        this.Cu = Cu
        this.Cd = Cd
        this.Ccch = Ccch
        this.Ccu = Ccu
        this.Ccd = Ccd
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Test>()
        if (size != 12) {
            throw Exception("Size of Test is not 12 but ${size} bytes")
        }
        let align = alignOf<Test>()
        if (align != 1) {
            throw Exception("Alignment of Test is not 1 but ${align} bytes")
        }
}
