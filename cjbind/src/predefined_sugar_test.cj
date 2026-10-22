package cjbind

import cjbind.ir.{CjbindContext, Item}
import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class PredefinedSugarTest {
    @TestCase
    func keepsBuiltinReturnTypesAtTheTargetWidth(): Unit {
        for ((target, integerType) in [
            ("x86_64-unknown-linux-gnu", "UInt64"),
            ("i686-unknown-linux-gnu", "UInt32"),
            ("x86_64-w64-mingw32", "UInt64")
        ]) {
            let options = CjbindOptions()
            options.headers.add("cjbind_test/testdata/headers/support/ir/predefined-sugar.h")
            options.noDetectIncludePath = true
            options.clangArgs.add(all: ["-x", "c", "--target=${target}"])
            let binding = generate(options)
            @Expect(binding.contains("foreign func strlen ( s: CPointer<UInt8> ) : ${integerType}"), true)
            @Expect(binding.contains("public type BuiltinSize = ${integerType}"), true)
            @Expect(binding.contains("immutable: CPointer<BuiltinSize> , mutable_value: CPointer<BuiltinSize>"), true)
        }
    }

    @TestCase
    func preservesConstThroughCanonicalBuiltinTypes(): Unit {
        let header = "cjbind_test/testdata/headers/support/ir/predefined-sugar.h"
        let options = CjbindOptions()
        options.headers.add(header)
        options.noDetectIncludePath = true
        options.clangArgs.add(all: ["-x", "c", "--target=x86_64-unknown-linux-gnu", header])
        let ctx = CjbindContext(options)
        try {
            var checked = 0
            for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                if (cursor.spelling() == "frozen_size") {
                    let parsed = Item.fromTy(cursor.curType(), cursor, None, ctx).ok().getOrThrow()
                    @Expect(ctx.resolveType(parsed).isConst, true)
                    checked += 1
                } else if (cursor.spelling() == "inspect_sizes") {
                    for ((index, argument) in cursor.args().getOrThrow().iterator().enumerate()) {
                        let pointee = argument.curType().pointeeType().getOrThrow()
                        let parsed = Item.fromTy(pointee, argument, None, ctx).ok().getOrThrow()
                        @Expect(ctx.resolveType(parsed).isConst, index == 0)
                        checked += 1
                    }
                }
            }
            @Expect(checked, 3)
        } finally {
            ctx.close()
        }
    }
}
