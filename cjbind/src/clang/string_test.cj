package cjbind.clang

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class StringLiteralEvaluationTest {
    @TestCase
    func decodesCanonicalSpellingWithoutLosingNulBytes(): Unit {
        let expected: Array<UInt8> = [97, 0, 98, 0, 255]
        @Expect(decodeClangStringLiteral(#""a\000b\000\377""#).getOrThrow(), expected)
        @Expect(decodeClangStringLiteral(#"u8"a\000b\000\377""#).getOrThrow(), expected)
        @Expect(decodeClangStringLiteral(#""""#).getOrThrow().size, 0)
    }

    @TestCase
    func decodesCanonicalEscapesAndUtf8Bytes(): Unit {
        let controls: Array<UInt8> = [7, 8, 9, 10, 11, 12, 13, 92, 34, 39, 63]
        @Expect(decodeClangStringLiteral(#""\a\b\t\n\v\f\r\\\"\'\?""#).getOrThrow(), controls)
        @Expect(
            String.fromUtf8(decodeClangStringLiteral(#""\344\273\223\351\242\211""#).getOrThrow()),
            "仓颉"
        )
    }

    @TestCase
    func rejectsUnsupportedOrMalformedCanonicalSpellings(): Unit {
        for (spelling in [
            "", #"L"wide""#, #"u"utf16""#, #"U"utf32""#,
            #""\0""#, #""\400""#, #""\378""#, #""\x00""#, #""unterminated"#
        ]) {
            @Expect(decodeClangStringLiteral(spelling).isNone(), true)
        }
    }

    @TestCase
    func readsLiteralBytesFromArraysPointersAndMacroExpansions(): Unit {
        let header = "cjbind_test/testdata/headers/support/clang/string-literals.h"
        for (language in ["c", "c++"]) {
            let index = Index(false, false)
            try {
                let tu = TranslationUnit(index, header, ["-x", language], CXTranslationUnit_Flags_CXTranslationUnit_None)
                try {
                    var found = 0
                    for (declaration in tu.cursor().collectChildren()) {
                        if (declaration.kind() != CXCursorKind_CXCursor_VarDecl) {
                            continue
                        }
                        let name = declaration.spelling()
                        if (name == "offset" || name == "conditional") {
                            @Expect(evaluatedStringLiteral(declaration).isNone(), true)
                            try (evaluated = declaration.evalutate()) {
                                @Expect(evaluated.asLiteralBytes().isNone(), true)
                            }
                            continue
                        }
                        let evaluated = declaration.evalutate()
                        let bytes = try {
                            evaluated.asLiteralBytes().getOrThrow({=> Exception("missing bytes for ${name}")})
                        } finally {
                            evaluated.close()
                        }
                        // The returned array must remain valid after disposal.
                        let expected: Array<UInt8> = [97, 0, 98]
                        @Expect(bytes, expected)
                        found += 1
                    }
                    @Expect(found, 4)
                } finally {
                    tu.close()
                }
            } finally {
                index.close()
            }
        }
    }
}
