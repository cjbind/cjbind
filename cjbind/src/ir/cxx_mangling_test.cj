package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class CxxMethodManglingSelectionTest {
    @TestCase
    func prefersCompleteImplementationOverThunk(): Unit {
        let selected = selectNonAdjustingMethodMangling(
            ["_ZN7Derived5valueEv", "_ZThn8_N7Derived5valueEv"],
            "x86_64-unknown-linux-gnu",
            64
        )
        @Expect(selected.getOrThrow(), "_ZN7Derived5valueEv")
    }

    @TestCase
    func recognizesAllItaniumThunkForms(): Unit {
        @Expect(isAdjustingThunkMangling("_ZThn8_N1A1fEv", "x86_64-unknown-linux-gnu", 64), true)
        @Expect(isAdjustingThunkMangling("_ZTv0_n24_N1A1fEv", "x86_64-unknown-linux-gnu", 64), true)
        @Expect(isAdjustingThunkMangling("_ZTch0_h8_N1A1fEv", "x86_64-unknown-linux-gnu", 64), true)
        @Expect(isAdjustingThunkMangling("_ZN1A1fEv", "x86_64-unknown-linux-gnu", 64), false)
    }

    @TestCase
    func handlesPlatformSymbolPrefix(): Unit {
        @Expect(isAdjustingThunkMangling("__ZThn8_N1A1fEv", "arm64-apple-darwin", 64), true)
    }

    @TestCase
    func refusesThunkOnlySet(): Unit {
        let selected = selectNonAdjustingMethodMangling(
            ["_ZThn8_N1A1fEv", "_ZTv0_n24_N1A1fEv"],
            "x86_64-unknown-linux-gnu",
            64
        )
        @Expect(selected.isNone(), true)
    }
}
