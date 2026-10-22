package cjbind.ir

import cjbind.clang
import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ArrayConstQualificationTest {
    @TestCase
    func preservesNestedArrayConstnessWithoutFollowingPointers(): Unit {
        let header = "cjbind_test/testdata/headers/support/ir/const-arrays.h"
        let options = CjbindOptions()
        options.headers.add(header)
        options.clangArgs.add(all: ["-x", "c", header])
        let ctx = CjbindContext(options)
        try {
            var declarations = 0
            for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                if (cursor.kind() != clang.CXCursorKind_CXCursor_VarDecl) {
                    continue
                }
                declarations += 1
                let expectedConst = cursor.spelling().startsWith("const_")
                @Expect(cursor.curType().isConst(), expectedConst)
                let variable = match (Var.parse(cursor, ctx)) {
                    case Ok(ParseResult.New(value, _)) => value
                    case _ => throw Exception("failed to parse ${cursor.spelling()}")
                }
                @Expect(variable.isConst, expectedConst)
                @Expect(ctx.resolveType(variable.ty).isConst, expectedConst)
            }
            @Expect(declarations, 8)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func preservesConstnessOfMultidimensionalArrayParameter(): Unit {
        let header = "cjbind_test/testdata/headers/support/ir/const-arrays.h"
        let options = CjbindOptions()
        options.headers.add(header)
        options.clangArgs.add(all: ["-x", "c", header])
        let ctx = CjbindContext(options)
        try {
            var found = false
            for (cursor in ctx.translationUnit.cursor().collectChildren()) {
                if (cursor.spelling() != "takes_const_array") {
                    continue
                }
                found = true
                let argument = cursor.args().getOrThrow()[0]
                let typeId = Item.fromTy(argument.curType(), argument, None, ctx).ok().getOrThrow()
                @Expect(ctx.resolveType(typeId).isConst, true)
            }
            @Expect(found, true)
        } finally {
            ctx.close()
        }
    }
}
