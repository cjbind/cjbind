package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

@Test
public class CxxLanguageDetectionTest {
    @TestCase
    func headerExtensionFallback(): Unit {
        let cxx = CjbindOptions()
        cxx.headers.add("input.hpp")
        @Expect(usesCxxLanguage(cxx), true)

        let c = CjbindOptions()
        c.headers.add("input.h")
        @Expect(usesCxxLanguage(c), false)
    }

    @TestCase
    func lastSeparatedLanguageFlagWins(): Unit {
        let cxx = CjbindOptions()
        cxx.clangArgs.add(all: ["-x", "c", "-x", "c++"])
        @Expect(usesCxxLanguage(cxx), true)

        let c = CjbindOptions()
        c.clangArgs.add(all: ["-x", "c++", "-x", "c"])
        @Expect(usesCxxLanguage(c), false)
    }

    @TestCase
    func lastCompactLanguageFlagWins(): Unit {
        let options = CjbindOptions()
        options.clangArgs.add(all: ["-xc++", "-xc"])
        @Expect(usesCxxLanguage(options), false)
    }

    @TestCase
    func noneRestoresExtensionDetection(): Unit {
        let options = CjbindOptions()
        options.headers.add("input.hxx")
        options.clangArgs.add(all: ["-x", "c", "-x", "none"])
        @Expect(usesCxxLanguage(options), true)
    }
}
