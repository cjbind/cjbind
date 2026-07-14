package cjbind.clang

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class FallbackTranslationUnitTest {
    @TestCase
    func rejectsRecoveredTypesFromInvalidProbes(): Unit {
        let fallback = FallbackTranslationUnit(
            "target/fallback-probe-test.hpp",
            "target/fallback-probe-test.pch",
            ["-x", "c++", "-std=c++14"]
        )
        try {
            @Expect(fallback.probeType("int").isSome(), true)
            @Expect(fallback.probeType("UndeclaredProbeType").isNone(), true)
        } finally {
            fallback.close()
        }
    }
}
