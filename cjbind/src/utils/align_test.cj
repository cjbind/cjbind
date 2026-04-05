package cjbind.utils

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class SprintAlignTest {
    @TestCase
    func emptyArrays(): Unit {
        let result = sprintAlign([], [])
        @Expect(result, "")
    }

    @TestCase
    func singleEntry(): Unit {
        let result = sprintAlign(["foo"], ["bar"])
        // "foo" padded to maxLen(3) + 3 = 6 chars, prefixed with default indent "    "
        @Expect(result.contains("foo"), true)
        @Expect(result.contains("bar"), true)
        @Expect(result.startsWith("    "), true)
        @Expect(result.endsWith("\n"), true)
    }

    @TestCase
    func alignment(): Unit {
        let result = sprintAlign(["a", "long_name"], ["1", "2"])
        let lines = result.split("\n", removeEmpty: true)
        @Expect(lines.size, 2)
        // Both "1" and "2" should start at the same column
        let pos1 = lines[0].indexOf("1")
        let pos2 = lines[1].indexOf("2")
        @Expect(pos1, pos2)
    }

    @TestCase
    func customIndent(): Unit {
        let result = sprintAlign(["x"], ["y"], insert: "\t")
        @Expect(result.startsWith("\t"), true)
    }

    @TestCase
    func mismatchedLengthsThrows(): Unit {
        var threw = false
        try {
            let _ = sprintAlign(["a"], ["b", "c"])
        } catch (_: Exception) {
            threw = true
        }
        @Expect(threw, true)
    }

    @TestCase
    func paddingCalculation(): Unit {
        // maxLen = 5 ("hello"), pad = 5 + 3 = 8
        let result = sprintAlign(["hello", "hi"], ["world", "there"])
        let lines = result.split("\n", removeEmpty: true)
        // "hi" should be padded to 8 chars
        @Expect(lines[1].contains("hi"), true)
        @Expect(lines[1].contains("there"), true)
    }
}
