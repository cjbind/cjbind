package cjbind.ir

import cjbind.options.{ConfiguredCanDerive, ConfiguredDeriveTrait}
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class DeriveAnalysisOptionGatingTest {
    @TestCase
    func invokesBlocklistedTraitPolicyOnlyForEnabledAnalyses(): Unit {
        let ctx = analysisTestContext()
        try {
            let copyCalls = Box(0)
            let debugCalls = Box(0)
            let disabledCalls = Box(0)
            ctx.options.blocklistedTypes.add(#"^External$"#)
            ctx.options.blocklistedTypeImplementsTraitCallback = Some({
                _: String, deriveTrait: ConfiguredDeriveTrait =>
                match (deriveTrait) {
                    case ConfiguredDeriveTrait.Copy => copyCalls.value += 1
                    case ConfiguredDeriveTrait.Debug => debugCalls.value += 1
                    case _ => disabledCalls.value += 1
                }
                Some(ConfiguredCanDerive.Yes)
            })

            let external = addAnalysisTestType(
                ctx,
                "External",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let holder = addAnalysisTestType(
                ctx,
                "Holder",
                TypeKind.TypeKindComp(analysisTestRecord([external]))
            )
            ctx.allowlistedItems = Some(analysisTestItems([holder]))

            ctx.computeCoreAnalyses()
            ctx.computeDeriveAnalyses()

            @Expect(copyCalls.value, 1)
            @Expect(debugCalls.value, 1)
            @Expect(disabledCalls.value, 0)
            @Expect(ctx.cannotDeriveDefault.isNone(), true)
            @Expect(ctx.cannotDeriveHash.isNone(), true)
            @Expect(ctx.cannotDerivePartialEqOrPartialOrd.isNone(), true)
            @Expect(ctx.hasFloatResults.isNone(), true)
        } finally {
            ctx.close()
        }
    }
}
