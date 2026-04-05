package cjbind_token

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.ArrayList
import cjbind_token.macros.*

@Test
public class SpacingTest {
    @TestCase
    func jointAndAlone(): Unit {
        let j = Spacing.Joint
        let a = Spacing.Alone
        @Expect(j != a, true)
    }
}

@Test
public class DelimiterTest {
    @TestCase
    func allVariants(): Unit {
        let p = Delimiter.Paren
        let b = Delimiter.Brace
        let br = Delimiter.Bracket
        let a = Delimiter.Angle
        let n = Delimiter.Invisible
        @Expect(p != b, true)
        @Expect(br != a, true)
        @Expect(a != n, true)
    }
}

@Test
public class TokenTreeTest {
    @TestCase
    func identConstruction(): Unit {
        let tt = TokenTree.Ident("foo")
        match (tt) {
            case Ident(s) => @Expect(s, "foo")
            case _ => @Expect(true, false)
        }
    }

    @TestCase
    func literalConstruction(): Unit {
        let tt = TokenTree.Literal("42")
        match (tt) {
            case Literal(s) => @Expect(s, "42")
            case _ => @Expect(true, false)
        }
    }

    @TestCase
    func punctConstruction(): Unit {
        let tt = TokenTree.Punct(r',', Spacing.Alone)
        match (tt) {
            case Punct(ch, sp) =>
                @Expect(ch, r',')
                @Expect(sp == Spacing.Alone, true)
            case _ => @Expect(true, false)
        }
    }

    @TestCase
    func groupConstruction(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("x"))
        let tt = TokenTree.Group(Delimiter.Paren, inner)
        match (tt) {
            case Group(d, s) =>
                @Expect(d == Delimiter.Paren, true)
                @Expect(s.isEmpty(), false)
            case _ => @Expect(true, false)
        }
    }
}

@Test
public class TokenStreamBasicTest {
    @TestCase
    func emptyStream(): Unit {
        let ts = TokenStream()
        @Expect(ts.isEmpty(), true)
        @Expect(ts.toString(), "")
    }

    @TestCase
    func appendSingleIdent(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Ident("hello"))
        @Expect(ts.isEmpty(), false)
        @Expect(ts.toString(), "hello")
    }

    @TestCase
    func appendMultipleIdents(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Ident("public"))
        ts.append(TokenTree.Ident("func"))
        ts.append(TokenTree.Ident("main"))
        @Expect(ts.toString(), "public func main")
    }

    @TestCase
    func extendStream(): Unit {
        let a = TokenStream()
        a.append(TokenTree.Ident("hello"))
        let b = TokenStream()
        b.append(TokenTree.Ident("world"))
        a.`extend`(b)
        @Expect(a.toString(), "hello world")
    }

    @TestCase
    func iterateTokens(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Ident("a"))
        ts.append(TokenTree.Ident("b"))
        var count = 0
        for (_ in ts) {
            count++
        }
        @Expect(count, 2)
    }
}

@Test
public class TokenStreamSpacingTest {
    @TestCase
    func jointPunctNoSpace(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Punct(r':', Spacing.Joint))
        ts.append(TokenTree.Punct(r':', Spacing.Alone))
        @Expect(ts.toString(), "::")
    }

    @TestCase
    func alonePunctAddsSpace(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Ident("a"))
        ts.append(TokenTree.Punct(r'+', Spacing.Alone))
        ts.append(TokenTree.Ident("b"))
        @Expect(ts.toString(), "a + b")
    }

    @TestCase
    func multiCharOperator(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Ident("x"))
        ts.append(TokenTree.Punct(r'+', Spacing.Joint))
        ts.append(TokenTree.Punct(r'=', Spacing.Alone))
        ts.append(TokenTree.Literal("1"))
        @Expect(ts.toString(), "x += 1")
    }

    @TestCase
    func arrowOperator(): Unit {
        let ts = TokenStream()
        ts.append(TokenTree.Punct(r'-', Spacing.Joint))
        ts.append(TokenTree.Punct(r'>', Spacing.Alone))
        @Expect(ts.toString(), "->")
    }
}

@Test
public class TokenStreamGroupTest {
    @TestCase
    func parenGroup(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("x"))
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Paren, inner))
        @Expect(ts.toString(), "(x)")
    }

    @TestCase
    func braceGroup(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("x"))
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Brace, inner))
        @Expect(ts.toString(), "{ x }")
    }

    @TestCase
    func bracketGroup(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("x"))
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Bracket, inner))
        @Expect(ts.toString(), "[x]")
    }

    @TestCase
    func angleGroup(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("T"))
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Angle, inner))
        @Expect(ts.toString(), "<T>")
    }

    @TestCase
    func emptyBraceGroup(): Unit {
        let inner = TokenStream()
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Brace, inner))
        @Expect(ts.toString(), "{}")
    }

    @TestCase
    func emptyParenGroup(): Unit {
        let inner = TokenStream()
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Paren, inner))
        @Expect(ts.toString(), "()")
    }

    @TestCase
    func nestedGroups(): Unit {
        let innermost = TokenStream()
        innermost.append(TokenTree.Ident("x"))
        let middle = TokenStream()
        middle.append(TokenTree.Group(Delimiter.Paren, innermost))
        let ts = TokenStream()
        ts.append(TokenTree.Group(Delimiter.Brace, middle))
        @Expect(ts.toString(), "{ (x) }")
    }

    @TestCase
    func noneDelimiterInvisible(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("x"))
        let ts = TokenStream()
        ts.append(TokenTree.Ident("a"))
        ts.append(TokenTree.Group(Delimiter.Invisible, inner))
        ts.append(TokenTree.Ident("b"))
        @Expect(ts.toString(), "a x b")
    }

    @TestCase
    func funcSignature(): Unit {
        let args = TokenStream()
        let ts = TokenStream()
        ts.append(TokenTree.Ident("func"))
        ts.append(TokenTree.Ident("main"))
        ts.append(TokenTree.Group(Delimiter.Paren, args))
        ts.append(TokenTree.Punct(r':', Spacing.Alone))
        ts.append(TokenTree.Ident("Unit"))
        @Expect(ts.toString(), "func main () : Unit")
    }
}

@Test
public class TokenStreamIndentTest {
    @TestCase
    func noneGroupIndentPropagation(): Unit {
        let body = TokenStream()
        body.appendLiteral("line1\nline2")
        let ts = TokenStream()
        ts.appendLiteral("{\n    ")
        ts.append(TokenTree.Group(Delimiter.Invisible, body))
        ts.appendLiteral("\n}")
        @Expect(ts.toString(), "{\n    line1\n    line2\n}")
    }
}

@Test
public class ToTokensTest {
    @TestCase
    func mockImpl(): Unit {
        let item = MockToTokens("hello")
        let ts = item.toTokenStream()
        @Expect(ts.toString(), "hello")
    }

    @TestCase
    func int64ToTokens(): Unit {
        let ts = TokenStream()
        Int64(42).appendToStream(ts)
        @Expect(ts.toString(), "42")
    }

    @TestCase
    func negativeInt64ToTokens(): Unit {
        let ts = TokenStream()
        Int64(-7).appendToStream(ts)
        @Expect(ts.toString(), "-7")
    }

    @TestCase
    func float64ToTokens(): Unit {
        let ts = TokenStream()
        Float64(3.14).appendToStream(ts)
        let s = ts.toString()
        @Expect(s.contains("+"), false)
        @Expect(s.contains("3.14"), true)
    }

    @TestCase
    func float64NegativeToTokens(): Unit {
        let ts = TokenStream()
        Float64(-2.5).appendToStream(ts)
        let s = ts.toString()
        @Expect(s.contains("-2.5"), true)
    }

    @TestCase
    func boolTrueToTokens(): Unit {
        let ts = TokenStream()
        true.appendToStream(ts)
        @Expect(ts.toString(), "true")
    }

    @TestCase
    func boolFalseToTokens(): Unit {
        let ts = TokenStream()
        false.appendToStream(ts)
        @Expect(ts.toString(), "false")
    }

    @TestCase
    func optionSomeToTokens(): Unit {
        let opt: ?TokenStream = Some(TokenStream())
        let ts = TokenStream()
        opt.getOrThrow().append(TokenTree.Ident("hello"))
        let result = TokenStream()
        optionAppendToStream(opt, result)
        @Expect(result.isEmpty(), false)
    }

    @TestCase
    func optionNoneToTokens(): Unit {
        let opt: ?TokenStream = Option<TokenStream>.None
        let result = TokenStream()
        optionAppendToStream(opt, result)
        @Expect(result.isEmpty(), true)
    }

    @TestCase
    func tokenStreamToTokens(): Unit {
        let inner = TokenStream()
        inner.append(TokenTree.Ident("a"))
        inner.append(TokenTree.Ident("b"))
        let outer = TokenStream()
        inner.appendToStream(outer)
        @Expect(outer.toString(), "a b")
    }

    @TestCase
    func tokenTreeToTokens(): Unit {
        let tt = TokenTree.Ident("x")
        let ts = TokenStream()
        tt.appendToStream(ts)
        @Expect(ts.toString(), "x")
    }
}

class MockToTokens <: ToTokens {
    let value: String
    init(value: String) {
        this.value = value
    }
    public func appendToStream(tokens: TokenStream): Unit {
        tokens.append(TokenTree.Ident(this.value))
    }
}

@Test
public class TokenStreamExtTest {
    @TestCase
    func appendSeparatedMultiple(): Unit {
        let items = ArrayList<TokenStream>()
        let a = TokenStream()
        a.append(TokenTree.Ident("a"))
        let b = TokenStream()
        b.append(TokenTree.Ident("b"))
        let c = TokenStream()
        c.append(TokenTree.Ident("c"))
        items.add(a)
        items.add(b)
        items.add(c)

        let ts = TokenStream()
        let comma = TokenStream()
        comma.append(TokenTree.Punct(r',', Spacing.Alone))
        ts.appendSeparated(items, comma)
        @Expect(ts.toString(), "a , b , c")
    }

    @TestCase
    func appendSeparatedSingle(): Unit {
        let items = ArrayList<TokenStream>()
        let a = TokenStream()
        a.append(TokenTree.Ident("only"))
        items.add(a)

        let ts = TokenStream()
        let comma = TokenStream()
        comma.append(TokenTree.Punct(r',', Spacing.Alone))
        ts.appendSeparated(items, comma)
        @Expect(ts.toString(), "only")
    }

    @TestCase
    func appendSeparatedEmpty(): Unit {
        let items = ArrayList<TokenStream>()
        let ts = TokenStream()
        let comma = TokenStream()
        comma.append(TokenTree.Punct(r',', Spacing.Alone))
        ts.appendSeparated(items, comma)
        @Expect(ts.isEmpty(), true)
    }

    @TestCase
    func appendTerminated(): Unit {
        let items = ArrayList<TokenStream>()
        let a = TokenStream()
        a.append(TokenTree.Ident("stmt1"))
        let b = TokenStream()
        b.append(TokenTree.Ident("stmt2"))
        items.add(a)
        items.add(b)

        let ts = TokenStream()
        let semi = TokenStream()
        semi.append(TokenTree.Punct(r';', Spacing.Alone))
        ts.appendTerminated(items, semi)
        @Expect(ts.toString(), "stmt1 ; stmt2 ;")
    }

    @TestCase
    func appendAllItems(): Unit {
        let items = ArrayList<TokenStream>()
        let a = TokenStream()
        a.append(TokenTree.Ident("a"))
        let b = TokenStream()
        b.append(TokenTree.Ident("b"))
        items.add(a)
        items.add(b)

        let ts = TokenStream()
        ts.appendAll(items)
        @Expect(ts.toString(), "a b")
    }
}

@Test
public class HelperFunctionsTest {
    @TestCase
    func identHelper(): Unit {
        let tt = ident("foo")
        let ts = TokenStream()
        ts.append(tt)
        @Expect(ts.toString(), "foo")
    }

    @TestCase
    func punctHelper(): Unit {
        let tt = punct(r',')
        let ts = TokenStream()
        ts.append(tt)
        @Expect(ts.toString(), ",")
    }

    @TestCase
    func punctJointHelper(): Unit {
        let tt = punct(r':', spacing: Spacing.Joint)
        let ts = TokenStream()
        ts.append(tt)
        ts.append(punct(r':'))
        @Expect(ts.toString(), "::")
    }

    @TestCase
    func groupHelper(): Unit {
        let inner = TokenStream()
        inner.append(ident("x"))
        let tt = group(Delimiter.Paren, inner)
        let ts = TokenStream()
        ts.append(tt)
        @Expect(ts.toString(), "(x)")
    }
}

@Test
public class IntegrationTest {
    @TestCase
    func foreignFuncDecl(): Unit {
        let ts = TokenStream()
        ts.append(ident("foreign"))
        ts.append(ident("func"))
        ts.append(ident("strlen"))
        let args = TokenStream()
        args.append(ident("s"))
        args.append(punct(r':', spacing: Spacing.Alone))
        args.append(ident("CString"))
        ts.append(group(Delimiter.Paren, args))
        ts.append(punct(r':', spacing: Spacing.Alone))
        ts.append(ident("UIntNative"))
        @Expect(ts.toString(), "foreign func strlen (s : CString) : UIntNative")
    }

    @TestCase
    func structDecl(): Unit {
        let fields = ArrayList<TokenStream>()

        let f1 = TokenStream()
        f1.append(ident("public"))
        f1.append(ident("let"))
        f1.append(ident("x"))
        f1.append(punct(r':', spacing: Spacing.Alone))
        f1.append(ident("Float64"))
        fields.add(f1)

        let f2 = TokenStream()
        f2.append(ident("public"))
        f2.append(ident("let"))
        f2.append(ident("y"))
        f2.append(punct(r':', spacing: Spacing.Alone))
        f2.append(ident("Float64"))
        fields.add(f2)

        let body = TokenStream()
        let newlineSep = TokenStream()
        newlineSep.appendLiteral("\n")
        body.appendSeparated(fields, newlineSep)

        let ts = TokenStream()
        ts.append(ident("@C"))
        ts.appendLiteral("\n")
        ts.append(ident("public"))
        ts.append(ident("struct"))
        ts.append(ident("Point"))

        let braceInner = TokenStream()
        braceInner.appendLiteral("\n")
        braceInner.append(group(Delimiter.Invisible, body))
        braceInner.appendLiteral("\n")

        ts.append(group(Delimiter.Brace, braceInner))
        let result = ts.toString()
        @Expect(result.contains("public let x : Float64"), true)
        @Expect(result.contains("public let y : Float64"), true)
    }

    @TestCase
    func constDecl(): Unit {
        let ts = TokenStream()
        ts.append(ident("public"))
        ts.append(ident("const"))
        ts.append(ident("MY_VAR"))
        ts.append(punct(r':', spacing: Spacing.Alone))
        ts.append(ident("Int32"))
        ts.append(punct(r'=', spacing: Spacing.Alone))
        ts.append(TokenTree.Literal("42"))
        @Expect(ts.toString(), "public const MY_VAR : Int32 = 42")
    }

    @TestCase
    func typeAlias(): Unit {
        let ts = TokenStream()
        ts.append(ident("public"))
        ts.append(ident("type"))
        ts.append(ident("MyInt"))
        ts.append(punct(r'=', spacing: Spacing.Alone))
        ts.append(ident("Int32"))
        @Expect(ts.toString(), "public type MyInt = Int32")
        // Note: = gets spaces on both sides because Alone spacing adds space to next token
    }

    @TestCase
    func pointerType(): Unit {
        let inner = TokenStream()
        inner.append(ident("UInt8"))
        let ts = TokenStream()
        ts.append(ident("CPointer"))
        ts.append(group(Delimiter.Angle, inner))
        @Expect(ts.toString(), "CPointer <UInt8>")
    }

    @TestCase
    func varrayType(): Unit {
        let inner = TokenStream()
        inner.append(ident("UInt8"))
        inner.append(punct(r',', spacing: Spacing.Alone))
        inner.appendLiteral("$16")
        let ts = TokenStream()
        ts.append(ident("VArray"))
        ts.append(group(Delimiter.Angle, inner))
        @Expect(ts.toString(), "VArray <UInt8 , $16>")
    }

    @TestCase
    func cfuncType(): Unit {
        let params = TokenStream()
        params.append(ident("Int32"))
        params.append(punct(r',', spacing: Spacing.Alone))
        params.append(ident("Int32"))

        let angleInner = TokenStream()
        angleInner.append(group(Delimiter.Paren, params))
        angleInner.append(punct(r'-', spacing: Spacing.Joint))
        angleInner.append(punct(r'>', spacing: Spacing.Alone))
        angleInner.append(ident("Int32"))

        let ts = TokenStream()
        ts.append(ident("CFunc"))
        ts.append(group(Delimiter.Angle, angleInner))
        @Expect(ts.toString(), "CFunc <(Int32 , Int32) -> Int32>")
    }
}

@Test
public class TmplRepetitionTest {
    @TestCase
    func commaSeparated(): Unit {
        let args = ArrayList<TokenStream>()
        args.add(tokenStreamFromTemplate("a: Int32"))
        args.add(tokenStreamFromTemplate("b: String"))
        args.add(tokenStreamFromTemplate("c: Bool"))
        let result = @tmpl(func foo($(${args}),*): Unit {})
        let s = result.toString()
        // joinStreams produces "a: Int32, b: String, c: Bool" via toString()
        // which gets interpolated into the template string
        @Expect(s.contains("a: Int32"), true)
        @Expect(s.contains("b: String"), true)
        @Expect(s.contains("c: Bool"), true)
        @Expect(s.contains("func foo"), true)
    }

    @TestCase
    func noSeparator(): Unit {
        let items = ArrayList<TokenStream>()
        items.add(tokenStreamFromTemplate("x"))
        items.add(tokenStreamFromTemplate("y"))
        items.add(tokenStreamFromTemplate("z"))
        let result = @tmpl($(${items})*)
        let s = result.toString()
        @Expect(s.contains("x"), true)
        @Expect(s.contains("y"), true)
        @Expect(s.contains("z"), true)
    }

    @TestCase
    func emptyList(): Unit {
        let args = ArrayList<TokenStream>()
        let result = @tmpl(func foo($(${args}),*): Unit {})
        let s = result.toString()
        @Expect(s.contains("func foo("), true)
        @Expect(s.contains("): Unit"), true)
    }

    @TestCase
    func singleItem(): Unit {
        let args = ArrayList<TokenStream>()
        args.add(tokenStreamFromTemplate("x: Int32"))
        let result = @tmpl(func foo($(${args}),*): Unit {})
        let s = result.toString()
        @Expect(s.contains("x: Int32"), true)
    }

    @TestCase
    func basicTmpl(): Unit {
        let name = "myFunc"
        let ret = tokenStreamFromTemplate("Int32")
        let result = @tmpl(public func ${name}(): ${ret} {})
        let s = result.toString()
        @Expect(s.contains("public func myFunc(): Int32 {}"), true)
    }
}
