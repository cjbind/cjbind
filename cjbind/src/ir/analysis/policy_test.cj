package cjbind.ir.analysis

import cjbind.ir.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class SemanticOpacityPolicyTest {
    @TestCase
    func packingOnlyAffectsTargetLayoutRepresentation(): Unit {
        let ctx = analysisTestContext()
        try {
            let packed = analysisTestRecord(Array<TypeId>())
            packed.packedAttr = true

            @Expect(packed.isSemanticallyOpaque(ctx), false)
            @Expect(packed.isCodegenOpaque(ctx, Some(Layout(1, 1))), true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func nonTypeParametersAndDependentBitfieldsAreSemanticallyOpaque(): Unit {
        let ctx = analysisTestContext()
        try {
            let nonType = analysisTestRecord(Array<TypeId>())
            nonType.hasNonTypeTemplateParams = true
            let dependentBitfield = analysisTestRecord(Array<TypeId>())
            dependentBitfield.hasUnevaluableBitFieldWidth = true

            @Expect(nonType.isSemanticallyOpaque(ctx), true)
            @Expect(dependentBitfield.isSemanticallyOpaque(ctx), true)
        } finally {
            ctx.close()
        }
    }
}
