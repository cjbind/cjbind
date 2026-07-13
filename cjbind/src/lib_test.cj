package cjbind

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

@Test
public class GenerateValidationTest {
    @TestCase
    func rejectsMissingHeaders(): Unit {
        var rejected = false
        try {
            generate(CjbindOptions())
        } catch (e: Exception) {
            rejected = e.message.contains("没有指定头文件")
        }
        @Expect(rejected, true)
    }
}
