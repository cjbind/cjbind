package cjbind.ir

import cjbind.clang
import cjbind.options.CjbindOptions
import std.env.getTempDirectory
import std.fs.{Directory, File, Path, exists, remove}
import std.unittest.*
import std.unittest.testmacro.*

func isolatedMacroValue(ctx: CjbindContext): Int64 {
    for (cursor in ctx.translationUnit.cursor().collectChildren()) {
        if (cursor.kind() != clang.CXCursorKind_CXCursor_MacroDefinition || cursor.spelling() != "ISOLATED_VALUE") {
            continue
        }
        let (_, value) = parseMacroClangFallback(ctx, cursor).getOrThrow({
            => Exception("isolated macro was silently dropped")
        })
        match (value) {
            case MacroEvalResult.EvalResultInt(Ints.Int(number)) => return number
            case _ => throw Exception("isolated macro has the wrong kind")
        }
    }
    throw Exception("isolated macro was not found")
}

@Test
public class MacroFallbackIsolationTest {
    @TestCase
    func simultaneousContextsOwnTheirFilesUntilClosed(): Unit {
        for (language in ["c", "c++"]) {
            let directory = Directory.createTemp(getTempDirectory())
            let header = directory.join("same.h")
            File.writeTo(header, "#define ISOLATED_VALUE CONFIG_VALUE\n".toArray())
            try {
                let firstOptions = CjbindOptions([header.toString()], [
                    "-x", language, "-DCONFIG_VALUE=17", header.toString()
                ])
                let secondOptions = CjbindOptions([header.toString()], [
                    "-x", language, "-DCONFIG_VALUE=42", header.toString()
                ])
                let first = CjbindContext(firstOptions)
                let second = CjbindContext(secondOptions)
                try {
                    let firstFallback = first.tryEnsureFallbackTranslationUnit().getOrThrow()
                    let secondFallback = second.tryEnsureFallbackTranslationUnit().getOrThrow()
                    let firstDirectory = Path(firstFallback.pchPath).parent
                    let secondDirectory = Path(secondFallback.pchPath).parent
                    @Expect(firstDirectory != secondDirectory, true)
                    @Expect(firstFallback.filePath != secondFallback.filePath, true)
                    @Expect(exists(firstDirectory), true)
                    @Expect(exists(secondDirectory), true)
                    @Expect(isolatedMacroValue(first), 17)
                    @Expect(isolatedMacroValue(second), 42)

                    first.close()
                    @Expect(exists(firstDirectory), false)
                    @Expect(exists(secondDirectory), true)
                    @Expect(isolatedMacroValue(second), 42)
                    @Expect(first.tryEnsureFallbackTranslationUnit().isNone(), true)

                    second.close()
                    @Expect(exists(secondDirectory), false)
                } finally {
                    first.close()
                    second.close()
                }
            } finally {
                remove(header)
                remove(directory)
            }
        }
    }

    @TestCase
    func failedFallbackInitializationReleasesItsDirectoryAndCanRetry(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        let header = directory.join("retry.h")
        let contents = "#define ISOLATED_VALUE 23\n"
        File.writeTo(header, contents.toArray())
        try {
            let options = CjbindOptions([header.toString()], ["-x", "c", header.toString()])
            let ctx = CjbindContext(options)
            try {
                // Clang can save a PCH containing #error diagnostics. A missing
                // input reliably fails initialization before a fallback TU exists.
                remove(header)
                var failed = false
                try {
                    ctx.tryEnsureFallbackTranslationUnit()
                } catch (e: Exception) {
                    failed = e.message.contains("parse failed")
                }
                @Expect(failed, true)
                @Expect(ctx.fallbackTu.isNone(), true)
                @Expect(ctx.fallbackDirectory.isNone(), true)
                File.writeTo(header, contents.toArray())
                let fallback = ctx.tryEnsureFallbackTranslationUnit().getOrThrow()
                let fallbackDirectory = Path(fallback.pchPath).parent
                @Expect(isolatedMacroValue(ctx), 23)
                ctx.close()
                @Expect(exists(fallbackDirectory), false)
            } finally {
                ctx.close()
            }
        } finally {
            remove(header)
            remove(directory)
        }
    }
}
