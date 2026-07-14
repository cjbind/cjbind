package cjbind.ir

import std.collection.HashMap
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class AnalysisQueryCompositionTest {
    @TestCase
    func equalityAndOrderingRejectFloatingPointTransitively(): Unit {
        let ctx = analysisTestContext()
        try {
            ctx.deriveEq = true
            ctx.deriveOrd = true
            ctx.derivePartialEq = true
            ctx.derivePartialOrd = true
            let integer = addAnalysisTestType(
                ctx,
                "Integer",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindFloat)
            )
            ctx.cannotDerivePartialEqOrPartialOrd = Some(HashMap<ItemId, CanDerive>())
            ctx.hasFloatResults = Some(analysisTestItems([floating]))

            @Expect(ctx.canDeriveEq(integer), true)
            @Expect(ctx.canDeriveOrd(integer), true)
            @Expect(ctx.canDeriveEq(floating), false)
            @Expect(ctx.canDeriveOrd(floating), false)
            @Expect(ctx.canDerivePartialEq(integer), true)
            @Expect(ctx.canDerivePartialOrd(integer), true)
            @Expect(ctx.canDerivePartialEq(floating), true)
            @Expect(ctx.canDerivePartialOrd(floating), true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func arrayTypeParameterResultOverridesCopyDerivation(): Unit {
        let ctx = analysisTestContext()
        try {
            let array = addAnalysisTestType(
                ctx,
                "DependentArray",
                TypeKind.TypeKindArray(
                    addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam),
                    4
                )
            )
            ctx.cannotDeriveCopy = Some(HashMap<ItemId, CanDerive>())
            ctx.hasTypeParameterInArrayResults = Some(analysisTestItems([array]))

            @Expect(ctx.canDerive(array, DeriveTrait.Copy), CanDerive.No)
        } finally {
            ctx.close()
        }
    }
}
