package cjbind_ffi

public type Char_Char = UInt8

public type SChar_SChar = Int8

public type UChar_UChar = UInt8

@C
public struct Test_Test {
    public let ch: UInt8
    public let u: UInt8
    public let d: Int8
    public let cch: UInt8
    public let cu: UInt8
    public let cd: Int8
    public let Cch: Char_Char
    public let Cu: UChar_UChar
    public let Cd: SChar_SChar
    public let Ccch: Char_Char
    public let Ccu: UChar_UChar
    public let Ccd: SChar_SChar
    public func clone(): Test_Test {
        return this
    }
    public func toString(): String {
        var output = "Test_Test {"
        output += " ch: "
        output += this.ch.toString()
        output += ", u: "
        output += this.u.toString()
        output += ", d: "
        output += this.d.toString()
        output += ", cch: "
        output += this.cch.toString()
        output += ", cu: "
        output += this.cu.toString()
        output += ", cd: "
        output += this.cd.toString()
        output += ", Cch: "
        output += this.Cch.toString()
        output += ", Cu: "
        output += this.Cu.toString()
        output += ", Cd: "
        output += this.Cd.toString()
        output += ", Ccch: "
        output += this.Ccch.toString()
        output += ", Ccu: "
        output += this.Ccu.toString()
        output += ", Ccd: "
        output += this.Ccd.toString()
        output += " }"
        return output
    }
    public init(ch: UInt8, u: UInt8, d: Int8, cch: UInt8, cu: UInt8, cd: Int8, Cch: Char_Char, Cu: UChar_UChar,
        Cd: SChar_SChar, Ccch: Char_Char, Ccu: UChar_UChar, Ccd: SChar_SChar) {
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
        let size = sizeOf<Test_Test>()
        if (size != 12) {
            throw Exception("Size of Test_Test is not 12 but ${size} bytes")
        }
        let align = alignOf<Test_Test>()
        if (align != 1) {
            throw Exception("Alignment of Test_Test is not 1 but ${align} bytes")
        }
}
