package cjbind.ir.analysis

import cjbind.ir.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class CanonicalTemplateInstantiationRegressionTest {
    @TestCase
    func preservesTemplateAliasIdentityDuringCanonicalResolution(): Unit {
        let ctx = analysisTestContext()
        try {
            let target = addAnalysisTestType(ctx, "Target", TypeKind.TypeKindOpaque)
            let alias = addAnalysisTestType(
                ctx,
                "Alias",
                TypeKind.TypeKindTemplateAlias(target, Array<TypeId>())
            )

            @Expect(canonicalItemId(ctx, alias), alias)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func rejectsCanonicalAliasCycles(): Unit {
        let ctx = analysisTestContext()
        try {
            let left = addAnalysisTestType(ctx, "Left", TypeKind.TypeKindOpaque)
            let right = addAnalysisTestType(ctx, "Right", TypeKind.TypeKindOpaque)
            ctx.resolveType(left).kind = TypeKind.TypeKindAlias(right)
            ctx.resolveType(right).kind = TypeKind.TypeKindAlias(left)

            @Expect(ctx.resolveType(left).safeCanonicalType(ctx).isNone(), true)
            @Expect(ctx.resolveType(right).safeCanonicalType(ctx).isNone(), true)
        } finally {
            ctx.close()
        }
    }
}
