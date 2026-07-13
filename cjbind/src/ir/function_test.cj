package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class CompleteObjectManglingTest {
    @TestCase
    func ignoresQualifiedNameAndParameterCollisions(): Unit {
        let constructorManglings = ["_ZN1AC2EN1C1EE", "_ZN1AC1EN1C1EE"]
        @Expect(isCompleteObjectVariant(constructorManglings[1], constructorManglings, 67u8), true)
        @Expect(isCompleteObjectVariant(constructorManglings[0], constructorManglings, 67u8), false)

        let qualifiedNameManglings = ["_ZN1C1EC2Ev", "_ZN1C1EC1Ev"]
        @Expect(isCompleteObjectVariant(qualifiedNameManglings[1], qualifiedNameManglings, 67u8), true)
        @Expect(isCompleteObjectVariant(qualifiedNameManglings[0], qualifiedNameManglings, 67u8), false)
    }

    @TestCase
    func acceptsDestructorAbiTags(): Unit {
        let manglings = ["_ZN1VD2B1xEv", "_ZN1VD1B1xEv", "_ZN1VD0B1xEv"]
        @Expect(isCompleteObjectVariant(manglings[1], manglings, 68u8), true)
        @Expect(isCompleteObjectVariant(manglings[0], manglings, 68u8), false)
        @Expect(isCompleteObjectVariant(manglings[2], manglings, 68u8), false)
    }

    @TestCase
    func removesOnlyTargetPlatformDecoration(): Unit {
        @Expect(normalizePlatformMangling("__Z3fooi", false, "x86_64-apple-darwin", 64), "_Z3fooi")
        @Expect(normalizePlatformMangling("_foo", false, "arm64-apple-ios", 64), "foo")
        @Expect(normalizePlatformMangling("__Z5freesi@4", true, "i686-w64-windows-gnu", 32), "_Z5freesi")
        @Expect(normalizePlatformMangling("_cf@4", true, "i686-pc-win32", 32), "cf")
        @Expect(normalizePlatformMangling("_Z3fooi", false, "i686-unknown-linux-gnu", 32), "_Z3fooi")
    }

    @TestCase
    func namesUnsupportedCallingConventions(): Unit {
        @Expect(Known(Abi.ThisCall).diagnosticName(), "thiscall")
        @Expect(Known(Abi.Fastcall).diagnosticName(), "fastcall")
        @Expect(Known(Abi.Vectorcall).diagnosticName(), "vectorcall")
        @Expect(Unknown(222u32).diagnosticName(), "unknown (222)")
    }
}
