package cjbind_test

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

func testDirectiveFails(action: () -> Unit): Bool {
    try {
        action()
        return false
    } catch (_: Exception) {
        return true
    }
}

@Test
public class HarnessOptionsTest {
    @TestCase
    func passesEveryArgumentAfterDelimiterToClang(): Unit {
        let opt = CjbindOptions()
        applyTestOptionLine(
            opt,
            "--enable-cxx-namespaces -- -x c++ -std=c++20 --unknown-to-harness",
            "inline"
        )

        @Expect(opt.enableCxxNamespaces, true)
        @Expect(opt.clangArgs.size, 4)
        @Expect(opt.clangArgs[0], "-x")
        @Expect(opt.clangArgs[1], "c++")
        @Expect(opt.clangArgs[2], "-std=c++20")
        @Expect(opt.clangArgs[3], "--unknown-to-harness")
    }

    @TestCase
    func rejectsUnknownMissingAndInvalidOptions(): Unit {
        @Expect(testDirectiveFails {=>
            applyTestOptionLine(CjbindOptions(), "--unknown", "inline")
        }, true)
        @Expect(testDirectiveFails {=>
            applyTestOptionLine(CjbindOptions(), "--allowlist-type --", "inline")
        }, true)
        @Expect(testDirectiveFails {=>
            applyTestOptionLine(CjbindOptions(), "--default-enum-style invalid", "inline")
        }, true)
        @Expect(testDirectiveFails {=>
            applyTestOptionLine(CjbindOptions(), "--generate types,invalid", "inline")
        }, true)
        @Expect(testDirectiveFails {=>
            applyTestOptionLine(CjbindOptions(), "--", "inline")
        }, true)
    }
}
