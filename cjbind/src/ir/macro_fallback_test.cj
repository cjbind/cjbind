package cjbind.ir

import cjbind.clang
import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class MacroFallbackEvaluationTest {
    @TestCase
    func preservesExplicitHeaderPathsWhenBasenamesCollide(): Unit {
        let fixture = "cjbind_test/testdata/headers/support/ir/macro-paths"
        for (withSecondHeader in [false, true]) {
            for (withShadowDirectory in [false, true]) {
                let options = CjbindOptions()
                options.headers.add("${fixture}/first/config.h")
                if (withSecondHeader) {
                    options.headers.add("${fixture}/second/config.h")
                }
                options.headers.add("${fixture}/main.h")
                options.clangArgs.add(all: ["-x", "c"])
                if (withShadowDirectory) {
                    options.clangArgs.add("-I${fixture}/shadow")
                }
                for (i in 0..(options.headers.size - 1)) {
                    options.clangArgs.add(all: ["-include", options.headers[i]])
                }
                options.clangArgs.add("${fixture}/main.h")
                let macroName = if (withSecondHeader) { "TWO_CONFIG_VALUES" } else { "SINGLE_CONFIG_VALUE" }
                let expected = if (withSecondHeader) { 42 } else { 17 }
                let ctx = CjbindContext(options)
                try {
                    var found = false
                    for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                        if (cursor.kind() != clang.CXCursorKind_CXCursor_MacroDefinition || cursor.spelling() != macroName) {
                            continue
                        }
                        found = true
                        let (_, value) = parseMacroClangFallback(ctx, cursor).getOrThrow({
                            => Exception("macro from explicit header paths was silently dropped")
                        })
                        match (value) {
                            case MacroEvalResult.EvalResultInt(Ints.Int(number)) => @Expect(number, expected)
                            case _ => throw Exception("macro from explicit header paths has the wrong kind")
                        }
                    }
                    @Expect(found, true)
                } finally {
                    ctx.close()
                }
            }
        }
    }

    @TestCase
    func preservesDefinesIncludesAndLanguageOptions(): Unit {
        let prefix = "cjbind_test/testdata/headers/support/ir/macro-prefix.h"
        let header = "cjbind_test/testdata/headers/support/ir/macro-options.h"
        for (language in ["c", "c++"]) {
            let options = CjbindOptions()
            options.headers.add(all: [prefix, header])
            options.clangArgs.add(all: [
                "-x", language,
                if (language == "c") { "-std=c11" } else { "-std=c++20" },
                "-DCJBIND_CONFIG_VALUE=41",
                "-Icjbind_test/testdata/headers/support/ir/macro-includes",
                "-include", prefix, header
            ])
            let ctx = CjbindContext(options)
            try {
                var found = false
                for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                    if (cursor.kind() != clang.CXCursorKind_CXCursor_MacroDefinition || cursor.spelling() != "FROM_CONFIG") {
                        continue
                    }
                    found = true
                    let (_, value) = parseMacroClangFallback(ctx, cursor).getOrThrow({
                        => Exception("configured macro was silently dropped in ${language}")
                    })
                    match (value) {
                        case MacroEvalResult.EvalResultInt(Ints.Int(number)) => @Expect(number, 64)
                        case _ => throw Exception("configured macro has the wrong kind")
                    }
                }
                @Expect(found, true)
            } finally {
                ctx.close()
            }
        }
    }

    @TestCase
    func evaluatesStringExpressionWithItsCharacterType(): Unit {
        let header = "cjbind_test/testdata/headers/macro_const.h"
        let options = CjbindOptions()
        options.headers.add(header)
        options.clangArgs.add(all: ["-x", "c", header])
        let ctx = CjbindContext(options)
        try {
            var found = false
            for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                if (cursor.kind() != clang.CXCursorKind_CXCursor_MacroDefinition || cursor.spelling() != "foo") {
                    continue
                }
                found = true
                let (_, value) = parseMacroClangFallback(ctx, cursor).getOrThrow({
                    => Exception("string macro was silently dropped")
                })
                match (value) {
                    case MacroEvalResult.EvalStr(text) =>
                        @Expect(String.fromUtf8(text), "bar")
                    case _ => throw Exception("string macro has the wrong kind")
                }
            }
            @Expect(found, true)
        } finally {
            ctx.close()
        }
    }
}
