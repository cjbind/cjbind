package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

@Test
public class CxxLanguageInputsTest {
    @TestCase
    func recognizesSourceAndHeaderExtensions(): Unit {
        for (name in ["input.hh", "input.h++", "input.cpp", "input.cxx", "input.c++", "input.C"]) {
            let options = CjbindOptions()
            options.headers.add(name)
            @Expect(usesCxxLanguage(options), true)
        }
    }

    @TestCase
    func explicitLanguageOverridesExtension(): Unit {
        let options = CjbindOptions()
        options.headers.add("input.cpp")
        options.clangArgs.add(all: ["-x", "c"])
        @Expect(usesCxxLanguage(options), false)
    }

    @TestCase
    func compactNoneFallsBackToExtension(): Unit {
        let options = CjbindOptions()
        options.headers.add("input.hh")
        options.clangArgs.add(all: ["-xc", "-xnone"])
        @Expect(usesCxxLanguage(options), true)
    }
}
