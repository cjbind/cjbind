package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class CxxTemplateNameTest {
    @TestCase
    func qualifiesAndSeparatesArguments(): Unit {
        @Expect(
            templateInstantiationName("scope::Fixed<int, -4>"),
            "scope_Fixed_open0_int_minus_4_close0"
        )
    }

    @TestCase
    func preservesDistinctOperators(): Unit {
        @Expect(
            templateInstantiationName("Expr<(1 + 2) / 3>"),
            "Expr_open0_lparen_1_plus_2_rparen_slash_3_close0"
        )
    }

    @TestCase
    func escapesUnicodeAndLeadingDigit(): Unit {
        @Expect(
            templateInstantiationName("9<\u{03bb}>"),
            "template_9_open0__u955__close0"
        )
    }

    @TestCase
    func canonicalizesReferenceAndPointerTokens(): Unit {
        @Expect(
            templateInstantiationName("Box<const int*, Value&&>"),
            "Box_open0_const_int_ptr_Value_rref_close0"
        )
    }
}
