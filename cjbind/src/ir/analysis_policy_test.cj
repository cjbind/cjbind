package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.{ConfiguredCanDerive, ConfiguredDeriveTrait}

@Test
public class DerivePolicyAnalysisTest {
    @TestCase
    func blocklistedDependenciesUseTheConfiguredTraitResult(): Unit {
        let ctx = analysisTestContext()
        try {
            let callbackCalls = Box(0)
            ctx.options.blocklistedTypes.add(#"^BlockedLeaf$"#)
            ctx.options.blocklistedTypeImplementsTraitCallback = Some({
                name: String, deriveTrait: ConfiguredDeriveTrait =>
                callbackCalls.value += 1
                if (name == "BlockedLeaf" && deriveTrait == ConfiguredDeriveTrait.Copy) {
                    Some(ConfiguredCanDerive.Yes)
                } else {
                    Some(ConfiguredCanDerive.No)
                }
            })

            let blockedLeaf = addAnalysisTestType(
                ctx,
                "BlockedLeaf",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let holder = addAnalysisTestType(
                ctx,
                "Holder",
                TypeKind.TypeKindComp(analysisTestRecord([blockedLeaf]))
            )
            let roots = analysisTestItems([holder])

            @Expect(deriveTestResult(ctx, [holder], holder, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, [holder], holder, DeriveTrait.Debug), CanDerive.No)
            @Expect(
                analyzeCanDerive(ctx, roots, DeriveTrait.Copy)
                    .get(blockedLeaf)
                    .getOrDefault({=> CanDerive.Yes}),
                CanDerive.Yes
            )
            @Expect(analyzeCanDerive(ctx, roots, DeriveTrait.Debug).get(blockedLeaf).getOrThrow(), CanDerive.No)
            @Expect(callbackCalls.value, 2)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func manualBlocklistedResultsJoinForRecordsButRejectArrays(): Unit {
        let ctx = analysisTestContext()
        try {
            ctx.options.blocklistedTypeImplementsTraitCallback = Some({
                _: String, _: ConfiguredDeriveTrait => Some(ConfiguredCanDerive.Manually)
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
            let values = addAnalysisTestType(ctx, "Values", TypeKind.TypeKindArray(external, 4))

            @Expect(deriveTestResult(ctx, [holder], holder, DeriveTrait.Hash), CanDerive.Manually)
            @Expect(deriveTestResult(ctx, [values], values, DeriveTrait.Hash), CanDerive.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func noDerivePatternsAreAppliedPerTrait(): Unit {
        let ctx = analysisTestContext()
        try {
            ctx.options.noCopyTypes.add(#"^NoCopy$"#)
            ctx.options.noDebugTypes.add(#"^NoDebug$"#)
            ctx.options.noDefaultTypes.add(#"^NoDefault$"#)
            ctx.options.noHashTypes.add(#"^NoHash$"#)
            ctx.options.noPartialEqTypes.add(#"^NoPartialEq$"#)

            let noCopy = addAnalysisTestType(ctx, "NoCopy", TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>())))
            let noDebug = addAnalysisTestType(ctx, "NoDebug", TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>())))
            let noDefault = addAnalysisTestType(ctx, "NoDefault", TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>())))
            let noHash = addAnalysisTestType(ctx, "NoHash", TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>())))
            let noPartialEq = addAnalysisTestType(ctx, "NoPartialEq", TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>())))

            @Expect(deriveTestResult(ctx, [noCopy], noCopy, DeriveTrait.Copy), CanDerive.No)
            @Expect(deriveTestResult(ctx, [noDebug], noDebug, DeriveTrait.Debug), CanDerive.No)
            @Expect(deriveTestResult(ctx, [noDefault], noDefault, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, [noHash], noHash, DeriveTrait.Hash), CanDerive.No)
            @Expect(
                deriveTestResult(ctx, [noPartialEq], noPartialEq, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
            @Expect(deriveTestResult(ctx, [noCopy], noCopy, DeriveTrait.Debug), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func untaggedUnionRulesDistinguishCopyTemplatesAndOtherTraits(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let ordinaryComp = deriveTestUnion([integer])
            let ordinary = addAnalysisTestType(ctx, "OrdinaryUnion", TypeKind.TypeKindComp(ordinaryComp))
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let templateComp = deriveTestUnion([integer])
            templateComp.templateParams.add(parameter)
            let generic = addAnalysisTestType(ctx, "GenericUnion", TypeKind.TypeKindComp(templateComp))

            ctx.options.untaggedUnion = true
            @Expect(deriveTestResult(ctx, [integer, ordinary], ordinary, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, [integer, ordinary], ordinary, DeriveTrait.Debug), CanDerive.No)
            @Expect(deriveTestResult(ctx, [integer, parameter, generic], generic, DeriveTrait.Copy), CanDerive.No)

            ctx.options.untaggedUnion = false
            @Expect(deriveTestResult(ctx, [integer, ordinary], ordinary, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, [integer, parameter, generic], generic, DeriveTrait.Copy), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class SemanticOpacityPolicyTest {
    @TestCase
    func packingOnlyAffectsTargetLayoutRepresentation(): Unit {
        let ctx = analysisTestContext()
        try {
            let packed = analysisTestRecord(Array<TypeId>())
            packed.packedAttr = true

            @Expect(packed.isSemanticallyOpaque(ctx), false)
            @Expect(packed.isOpaqueForItem(ctx, Some(Layout(1, 1))), true)
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
