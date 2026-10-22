package cjbind_cli.arg

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class StringListFlagTest {
    @TestCase
    func repeatedOptionsPreserveEveryValue(): Unit {
        let flag = StringListFlag(None, "allowlist-type", "allowlist-type", "", "REGEX")
        let parser = ArgsParser(flag)

        let (headers, clangArgs) = parser.parse(
            [
                "cjbind",
                "--allowlist-type",
                "^First$",
                "--allowlist-type",
                "^Second$",
                "input.hpp"
            ]
        )

        @Expect(flag.values.size, 2)
        @Expect(flag.values[0], "^First$")
        @Expect(flag.values[1], "^Second$")
        @Expect(headers, ["input.hpp"])
        @Expect(clangArgs.size, 0)
    }
}

@Test
public class ArgsParserTest {
    @TestCase
    func preservesEveryClangArgumentAfterSeparator(): Unit {
        let flag = BoolFlag(None, "no-comment", "no-comment", "")
        let parser = ArgsParser(flag)

        let (headers, clangArgs) = parser.parse(["cjbind", "input.h", "--", "-x", "c", "--", "--no-comment"])

        @Expect(headers, ["input.h"])
        @Expect(clangArgs, ["-x", "c", "--", "--no-comment"])
        @Expect(flag.value, false)
    }
}
