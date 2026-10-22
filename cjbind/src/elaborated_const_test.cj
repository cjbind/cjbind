package cjbind

import cjbind.clang
import cjbind.ir.{CjbindContext, Item}
import cjbind.options.CjbindOptions
import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.process.executeWithOutput
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ElaboratedConstQualificationTest {
    @TestCase
    func preservesQualifiedUsesAndUnqualifiedDeclarations(): Unit {
        let header = "cjbind_test/testdata/headers/support/ir/const-elaborated.h"
        for (language in ["c", "c++"]) {
            let options = CjbindOptions()
            options.headers.add(header)
            options.noDetectIncludePath = true
            options.clangArgs.add(all: ["-x", language, "--target=x86_64-unknown-linux-gnu", header])
            let ctx = CjbindContext(options)
            try {
                var checked = 0
                var qualifiedElaborated = 0
                for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                    if (cursor.kind() != clang.CXCursorKind_CXCursor_VarDecl) {
                        continue
                    }
                    let ty = cursor.curType()
                    let expectedConst = cursor.spelling().startsWith("constant_")
                    @Expect(ty.isConst(), expectedConst)
                    if (expectedConst && ty.kind() == clang.CXTypeKind_CXType_Elaborated && !ty.named().isConst()) {
                        qualifiedElaborated += 1
                    }
                    let parsed = Item.fromTy(ty, cursor, None, ctx).ok().getOrThrow()
                    @Expect(ctx.resolveType(parsed).isConst, expectedConst)
                    checked += 1
                }
                @Expect(checked, 6)
                // LLVM 20 exposes these qualified uses through kind 119.
                // Newer versions may expose the qualified typedef directly.
                if (clang.getClangVersion().contains("version 20.")) {
                    @Expect(qualifiedElaborated > 0, true)
                }
            } finally {
                ctx.close()
            }
        }
    }

    @TestCase
    func keepsAliasNamesWhenPreservingQualifiers(): Unit {
        let options = CjbindOptions()
        options.headers.add("cjbind_test/testdata/headers/support/ir/const-elaborated.h")
        options.noDetectIncludePath = true
        options.clangArgs.add(all: ["-x", "c", "--target=x86_64-unknown-linux-gnu"])
        let binding = generate(options)
        @Expect(binding.contains("public type PlainAlias = UInt64"), true)
        @Expect(binding.contains("frozen: CPointer<PlainAlias> , mutable_value: CPointer<PlainAlias>"), true)
    }

    @TestCase
    func keepsConstInCompiledStaticWrappers(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("const_elaborated.h")
            File.writeTo(header, File.readFrom("cjbind_test/testdata/headers/support/ir/const-elaborated.h"))
            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.wrapStaticFns = true
            options.wrapStaticFnsPath = Some(directory.join("bridge.generated").toString())
            options.clangArgs.add(all: ["-x", "c", "--target=x86_64-unknown-linux-gnu"])
            let binding = generate(options)
            let source = directory.join("bridge.c")
            let sourceCode = String.fromUtf8(File.readFrom(source))
            @Expect(binding.contains("identity__extern ( value: CPointer<PlainAlias> ) : CPointer<PlainAlias>"), true)
            @Expect(sourceCode.contains("const PlainAlias *identity__extern(const PlainAlias *value)"), true)
            let (exitCode, _, _) = executeWithOutput(
                "clang",
                ["-std=c11", "-fsyntax-only", "-Werror=incompatible-pointer-types-discards-qualifiers", source.toString()]
            )
            @Expect(exitCode, 0)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
