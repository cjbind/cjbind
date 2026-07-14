package cjbind.ir

import std.collection.{ArrayList, HashMap}
import std.unittest.*
import std.unittest.testmacro.*

func deriveTestResult(
    ctx: CjbindContext,
    ids: Array<ItemId>,
    target: ItemId,
    deriveTrait: DeriveTrait
): CanDerive {
    let items = analysisTestItems(ids)
    if (ctx.haveVtable.isNone()) {
        ctx.haveVtable = Some(computeHasVtable(ctx, items))
    }
    if (ctx.haveDestructor.isNone()) {
        ctx.haveDestructor = Some(analyzeHasDestructor(ctx, items))
    }
    return analyzeCanDerive(ctx, items, deriveTrait)
        .get(target)
        .getOrDefault({=> CanDerive.Yes})
}

func addDeriveTestTypeWithLayout(
    ctx: CjbindContext,
    name: String,
    layout: Layout,
    kind: TypeKind
): TypeId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(id, None, ctx.rootModule, ItemKind.KindType(Type(Some(name), Some(layout), kind, false)), None),
        None,
        None
    )
    return id
}

func deriveTestArguments(ty: TypeId, count: Int64): Array<(?String, TypeId)> {
    let arguments = ArrayList<(?String, TypeId)>()
    for (_ in 0..count) {
        arguments.add((None, ty))
    }
    return arguments.toArray()
}

func deriveTestUnion(fields: Array<TypeId>): CompInfo {
    let comp = CompInfo(CompKind.CompKindUnion, isCxxRecord: true)
    let members = ArrayList<Field>()
    for (fieldType in fields) {
        members.add(Field.DataMember(RawField(None, fieldType, None, None, None)))
    }
    comp.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(members.toArray(), false))
    return comp
}

func addDeriveTestVar(ctx: CjbindContext, name: String, ty: TypeId): ItemId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(id, None, ctx.rootModule, ItemKind.KindVar(Var(name, ty, None, false)), None),
        None,
        None
    )
    return id
}

@Test
public class CanDeriveLatticeTest {
    @TestCase
    func joinSelectsTheMostRestrictiveResult(): Unit {
        @Expect(CanDerive.Yes.join(CanDerive.Yes), CanDerive.Yes)
        @Expect(CanDerive.Yes.join(CanDerive.Manually), CanDerive.Manually)
        @Expect(CanDerive.Manually.join(CanDerive.Yes), CanDerive.Manually)
        @Expect(CanDerive.Manually.join(CanDerive.No), CanDerive.No)
        @Expect(CanDerive.No.join(CanDerive.Yes), CanDerive.No)
        @Expect(CanDerive.No.join(CanDerive.Manually), CanDerive.No)
    }

    @TestCase
    func resultSetKeepsBothNonAutomaticStates(): Unit {
        let results = HashMap<ItemId, CanDerive>()
        results.add(1, CanDerive.Yes)
        results.add(2, CanDerive.Manually)
        results.add(3, CanDerive.No)

        let cannotDerive = asCannotDeriveSet(results)
        @Expect(cannotDerive.contains(1), false)
        @Expect(cannotDerive.contains(2), true)
        @Expect(cannotDerive.contains(3), true)
    }

    @TestCase
    func traitNamesAreStable(): Unit {
        @Expect(DeriveTrait.Copy.toString(), "Copy")
        @Expect(DeriveTrait.Debug.toString(), "Debug")
        @Expect(DeriveTrait.Default.toString(), "Default")
        @Expect(DeriveTrait.Hash.toString(), "Hash")
        @Expect(DeriveTrait.PartialEqOrPartialOrd.toString(), "PartialEq/PartialOrd")
    }
}

@Test
public class DeriveArrayRulesTest {
    @TestCase
    func defaultUsesTheThirtyTwoElementBoundary(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addDeriveTestTypeWithLayout(
                ctx,
                "Integer",
                Layout(4, 4),
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let atLimit = addAnalysisTestType(ctx, "AtLimit", TypeKind.TypeKindArray(integer, 32))
            let overLimit = addAnalysisTestType(ctx, "OverLimit", TypeKind.TypeKindArray(integer, 33))
            let ids = [integer, atLimit, overLimit]

            @Expect(deriveTestResult(ctx, ids, atLimit, DeriveTrait.Default), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, overLimit, DeriveTrait.Default), CanDerive.Manually)
            @Expect(deriveTestResult(ctx, ids, overLimit, DeriveTrait.Copy), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func incompleteArraysFollowTraitSpecificRules(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let incomplete = addAnalysisTestType(ctx, "Incomplete", TypeKind.TypeKindArray(integer, 0))
            let ids = [integer, incomplete]

            @Expect(deriveTestResult(ctx, ids, incomplete, DeriveTrait.Copy), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, incomplete, DeriveTrait.Hash), CanDerive.No)
            @Expect(
                deriveTestResult(ctx, ids, incomplete, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
            @Expect(deriveTestResult(ctx, ids, incomplete, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, incomplete, DeriveTrait.Default), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func arraysRejectElementsThatCannotDerive(): Unit {
        let ctx = analysisTestContext()
        try {
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let values = addAnalysisTestType(ctx, "Values", TypeKind.TypeKindArray(floating, 4))
            let ids = [floating, values]

            @Expect(deriveTestResult(ctx, ids, floating, DeriveTrait.Hash), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, values, DeriveTrait.Hash), CanDerive.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func excessiveAlignmentRequiresManualDefault(): Unit {
        let ctx = analysisTestContext()
        try {
            let aligned = addDeriveTestTypeWithLayout(
                ctx,
                "Aligned",
                Layout(64, 64),
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )

            @Expect(
                deriveTestResult(ctx, [aligned], aligned, DeriveTrait.Default),
                CanDerive.Manually
            )
            @Expect(deriveTestResult(ctx, [aligned], aligned, DeriveTrait.Copy), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DeriveVectorRulesTest {
    @TestCase
    func vectorsPropagateElementFailuresAndRejectCombinedOrdering(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(integer))
            let integers = addAnalysisTestType(ctx, "Integers", TypeKind.TypeKindVector(integer, 4))
            let floats = addAnalysisTestType(ctx, "Floats", TypeKind.TypeKindVector(floating, 4))
            let pointers = addAnalysisTestType(ctx, "Pointers", TypeKind.TypeKindVector(pointer, 4))
            let ids = [integer, floating, pointer, integers, floats, pointers]

            @Expect(deriveTestResult(ctx, ids, integers, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, integers, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, integers, DeriveTrait.Default), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, integers, DeriveTrait.Hash), CanDerive.Yes)
            @Expect(
                deriveTestResult(ctx, ids, integers, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
            @Expect(deriveTestResult(ctx, ids, floats, DeriveTrait.Hash), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, pointers, DeriveTrait.Default), CanDerive.No)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DeriveFunctionPointerRulesTest {
    @TestCase
    func parameterCountAndAbiControlNonStructuralTraits(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let supportedFunction = addAnalysisTestType(
                ctx,
                "SupportedFunction",
                TypeKind.TypeKindFunction(FunctionSig(
                    "supported",
                    integer,
                    deriveTestArguments(integer, 12),
                    false,
                    ClangAbi.Known(Abi.C)
                ))
            )
            let tooManyParametersFunction = addAnalysisTestType(
                ctx,
                "TooManyParametersFunction",
                TypeKind.TypeKindFunction(FunctionSig(
                    "tooManyParameters",
                    integer,
                    deriveTestArguments(integer, 13),
                    false,
                    ClangAbi.Known(Abi.C)
                ))
            )
            let nonCAbiFunction = addAnalysisTestType(
                ctx,
                "NonCAbiFunction",
                TypeKind.TypeKindFunction(FunctionSig(
                    "nonCAbi",
                    integer,
                    Array<(?String, TypeId)>(),
                    false,
                    ClangAbi.Known(Abi.Stdcall)
                ))
            )
            let supportedPointer = addAnalysisTestType(
                ctx,
                "SupportedPointer",
                TypeKind.TypeKindPointer(supportedFunction)
            )
            let tooManyParametersPointer = addAnalysisTestType(
                ctx,
                "TooManyParametersPointer",
                TypeKind.TypeKindPointer(tooManyParametersFunction)
            )
            let nonCAbiPointer = addAnalysisTestType(
                ctx,
                "NonCAbiPointer",
                TypeKind.TypeKindPointer(nonCAbiFunction)
            )
            let ids = [
                integer,
                supportedFunction,
                tooManyParametersFunction,
                nonCAbiFunction,
                supportedPointer,
                tooManyParametersPointer,
                nonCAbiPointer
            ]

            @Expect(deriveTestResult(ctx, ids, supportedPointer, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(
                deriveTestResult(ctx, ids, tooManyParametersPointer, DeriveTrait.Debug),
                CanDerive.Manually
            )
            @Expect(deriveTestResult(ctx, ids, nonCAbiPointer, DeriveTrait.Debug), CanDerive.Manually)
            @Expect(deriveTestResult(ctx, ids, nonCAbiPointer, DeriveTrait.Hash), CanDerive.No)
            @Expect(
                deriveTestResult(ctx, ids, nonCAbiPointer, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
            @Expect(deriveTestResult(ctx, ids, nonCAbiPointer, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, nonCAbiPointer, DeriveTrait.Default), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, supportedFunction, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(
                deriveTestResult(ctx, ids, tooManyParametersFunction, DeriveTrait.Debug),
                CanDerive.Manually
            )
            @Expect(deriveTestResult(ctx, ids, nonCAbiFunction, DeriveTrait.Hash), CanDerive.No)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DeriveCompoundRulesTest {
    @TestCase
    func forwardDeclarationsOnlyDeriveDebug(): Unit {
        let ctx = analysisTestContext()
        try {
            let forwardComp = analysisTestRecord(Array<TypeId>())
            forwardComp.isForwardDeclaration = true
            let forward = addAnalysisTestType(ctx, "Forward", TypeKind.TypeKindComp(forwardComp))

            @Expect(deriveTestResult(ctx, [forward], forward, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, [forward], forward, DeriveTrait.Copy), CanDerive.No)
            @Expect(deriveTestResult(ctx, [forward], forward, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, [forward], forward, DeriveTrait.Hash), CanDerive.No)
            @Expect(
                deriveTestResult(ctx, [forward], forward, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func destructorPreventsCopy(): Unit {
        let ctx = analysisTestContext()
        try {
            let destructorComp = analysisTestRecord(Array<TypeId>())
            destructorComp.hasDestructor = true
            let record = addAnalysisTestType(ctx, "WithDestructor", TypeKind.TypeKindComp(destructorComp))
            let ids = analysisTestItems([record])
            ctx.haveDestructor = Some(analyzeHasDestructor(ctx, ids))

            @Expect(deriveTestResult(ctx, [record], record, DeriveTrait.Copy), CanDerive.No)
            @Expect(deriveTestResult(ctx, [record], record, DeriveTrait.Debug), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, [record], record, DeriveTrait.Default), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func vtablePreventsDefault(): Unit {
        let ctx = analysisTestContext()
        try {
            let virtualComp = analysisTestRecord(Array<TypeId>())
            virtualComp.hasOwnVirtualMethod = true
            let record = addAnalysisTestType(ctx, "WithVtable", TypeKind.TypeKindComp(virtualComp))
            let ids = analysisTestItems([record])
            ctx.haveVtable = Some(computeHasVtable(ctx, ids))

            @Expect(deriveTestResult(ctx, [record], record, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, [record], record, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, [record], record, DeriveTrait.Debug), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func nonCopyUnionTraitsIgnoreFieldsWhileCopyStillPropagates(): Unit {
        let ctx = analysisTestContext()
        try {
            ctx.options.untaggedUnion = false
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let destructorComp = analysisTestRecord(Array<TypeId>())
            destructorComp.hasDestructor = true
            let nonCopy = addAnalysisTestType(ctx, "NonCopy", TypeKind.TypeKindComp(destructorComp))
            let hashUnion = addAnalysisTestType(ctx, "HashUnion", TypeKind.TypeKindComp(deriveTestUnion([floating])))
            let copyUnion = addAnalysisTestType(ctx, "CopyUnion", TypeKind.TypeKindComp(deriveTestUnion([nonCopy])))
            let ids = [floating, nonCopy, hashUnion, copyUnion]
            ctx.haveDestructor = Some(analyzeHasDestructor(ctx, analysisTestItems(ids)))

            @Expect(deriveTestResult(ctx, ids, hashUnion, DeriveTrait.Hash), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, hashUnion, DeriveTrait.Default), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, copyUnion, DeriveTrait.Copy), CanDerive.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func largeBitfieldUnitPreventsDefault(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addDeriveTestTypeWithLayout(
                ctx,
                "Integer",
                Layout(4, 4),
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let bitfieldData = RawField(Some("bits"), integer, None, Some(8), Some(0))
            let largeBitfieldComp = analysisTestRecord(Array<TypeId>())
            largeBitfieldComp.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(
                [Field.Bitfields(BitfieldUnit(0, Layout(33, 1), [Bitfield(0, bitfieldData)]))],
                true
            ))
            let record = addAnalysisTestType(ctx, "LargeBitfield", TypeKind.TypeKindComp(largeBitfieldComp))
            let ids = [integer, record]

            @Expect(deriveTestResult(ctx, ids, record, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, record, DeriveTrait.Copy), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func baseMembersAndBitfieldMembersConstrainTraits(): Unit {
        let ctx = analysisTestContext()
        try {
            let floating = addDeriveTestTypeWithLayout(
                ctx,
                "Floating",
                Layout(8, 8),
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let derivedComp = analysisTestRecord(Array<TypeId>())
            derivedComp.baseMembers.add(Base(floating, BaseKind.Normal, "base", true))
            let derived = addAnalysisTestType(ctx, "Derived", TypeKind.TypeKindComp(derivedComp))
            let bitfieldData = RawField(Some("bits"), floating, None, Some(8), Some(0))
            let bitfieldComp = analysisTestRecord(Array<TypeId>())
            bitfieldComp.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(
                [Field.Bitfields(BitfieldUnit(0, Layout(1, 1), [Bitfield(0, bitfieldData)]))],
                true
            ))
            let bitfieldRecord = addAnalysisTestType(
                ctx,
                "BitfieldRecord",
                TypeKind.TypeKindComp(bitfieldComp)
            )
            let ids = [floating, derived, bitfieldRecord]

            @Expect(deriveTestResult(ctx, ids, derived, DeriveTrait.Hash), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, bitfieldRecord, DeriveTrait.Hash), CanDerive.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func representationOpaqueRecordsUseTheirLayoutTraits(): Unit {
        let ctx = analysisTestContext()
        try {
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let packedComp = analysisTestRecord([floating])
            packedComp.packedAttr = true
            let packed = addAnalysisTestType(ctx, "Packed", TypeKind.TypeKindComp(packedComp))

            @Expect(deriveTestResult(ctx, [floating, packed], packed, DeriveTrait.Hash), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func semanticOpacityUsesLayoutTraitsExceptForUntaggedUnions(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(integer))
            let nonTypeComp = analysisTestRecord([pointer])
            nonTypeComp.hasNonTypeTemplateParams = true
            let nonTypeRecord = addAnalysisTestType(ctx, "NonTypeRecord", TypeKind.TypeKindComp(nonTypeComp))
            let opaque = addAnalysisTestType(ctx, "Opaque", TypeKind.TypeKindOpaque)
            let opaqueUnionComp = deriveTestUnion([pointer])
            opaqueUnionComp.forceOpaque = true
            let opaqueUnion = addAnalysisTestType(ctx, "OpaqueUnion", TypeKind.TypeKindComp(opaqueUnionComp))
            let ids = [integer, pointer, nonTypeRecord, opaque, opaqueUnion]

            @Expect(deriveTestResult(ctx, ids, nonTypeRecord, DeriveTrait.Default), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, opaque, DeriveTrait.Default), CanDerive.Yes)
            ctx.options.untaggedUnion = true
            @Expect(deriveTestResult(ctx, ids, opaqueUnion, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, opaqueUnion, DeriveTrait.Debug), CanDerive.No)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DeriveSimpleTypeRulesTest {
    @TestCase
    func floatHashAndDataPointerDefaultAreRejected(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let complex = addAnalysisTestType(
                ctx,
                "Complex",
                TypeKind.TypeKindComplex(TypeKindFloatKind.FloatKindDouble)
            )
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(integer))
            let ids = [integer, floating, complex, pointer]

            @Expect(deriveTestResult(ctx, ids, floating, DeriveTrait.Hash), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, complex, DeriveTrait.Hash), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, floating, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, pointer, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, pointer, DeriveTrait.Hash), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func voidReferenceAndTypeParameterCannotDeriveDefault(): Unit {
        let ctx = analysisTestContext()
        try {
            let voidType = addAnalysisTestType(ctx, "Void", TypeKind.TypeKindVoid)
            let parameter = addAnalysisTestType(ctx, "Parameter", TypeKind.TypeKindTypeParam)
            let reference = addAnalysisTestType(ctx, "Reference", TypeKind.TypeKindReference(parameter))
            let ids = [voidType, parameter, reference]

            @Expect(deriveTestResult(ctx, ids, voidType, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, parameter, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, reference, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, reference, DeriveTrait.Debug), CanDerive.Yes)
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let floatingReference = addAnalysisTestType(
                ctx,
                "FloatingReference",
                TypeKind.TypeKindReference(floating)
            )
            @Expect(
                deriveTestResult(ctx, [floating, floatingReference], floatingReference, DeriveTrait.Hash),
                CanDerive.Yes
            )
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DeriveReferenceEdgeRulesTest {
    @TestCase
    func aliasesBlockPointersAndVariablesPropagateReferencedResults(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(integer))
            let alias = addAnalysisTestType(ctx, "Alias", TypeKind.TypeKindAlias(pointer))
            let resolved = addAnalysisTestType(ctx, "Resolved", TypeKind.ResolvedTypeRef(alias))
            let blockPointer = addAnalysisTestType(
                ctx,
                "BlockPointer",
                TypeKind.TypeKindObjCBlockPointer(resolved)
            )
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(blockPointer, Array<TypeId>())
            )
            let variable = addDeriveTestVar(ctx, "value", pointer)
            let ids = [integer, pointer, alias, resolved, blockPointer, templateAlias, variable]

            @Expect(deriveTestResult(ctx, ids, alias, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, resolved, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, blockPointer, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, templateAlias, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, variable, DeriveTrait.Default), CanDerive.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func combinedEqualityIncludesTemplateParameterDefinitionEdges(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let vector = addAnalysisTestType(ctx, "Vector", TypeKind.TypeKindVector(integer, 4))
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(integer, [vector])
            )
            let comp = analysisTestRecord(Array<TypeId>())
            comp.templateParams.add(vector)
            let record = addAnalysisTestType(ctx, "Record", TypeKind.TypeKindComp(comp))
            let ids = [integer, vector, templateAlias, record]

            @Expect(deriveTestResult(ctx, ids, templateAlias, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(
                deriveTestResult(ctx, ids, templateAlias, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
            @Expect(deriveTestResult(ctx, ids, record, DeriveTrait.Copy), CanDerive.Yes)
            @Expect(
                deriveTestResult(ctx, ids, record, DeriveTrait.PartialEqOrPartialOrd),
                CanDerive.No
            )
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DeriveTemplateRulesTest {
    @TestCase
    func concreteInstantiationUsesDeclarationAndArgumentsOnly(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let vector = addAnalysisTestType(ctx, "Vector", TypeKind.TypeKindVector(integer, 4))
            let definition = addAnalysisTestType(
                ctx,
                "TemplateDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let concrete = addAnalysisTestType(
                ctx,
                "Concrete",
                TypeKind.TypeKindComp(analysisTestRecord([vector]))
            )
            ctx.concreteTemplateInstantiations.add(concrete, TemplateInstantiation(
                definition,
                [integer],
                ctx.translationUnit.cursor(),
                None
            ))

            @Expect(
                deriveTestResult(
                    ctx,
                    [integer, vector, definition, concrete],
                    concrete,
                    DeriveTrait.PartialEqOrPartialOrd
                ),
                CanDerive.Yes
            )
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func definitionAndArgumentsBothConstrainInstantiation(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(integer))
            let definition = addAnalysisTestType(
                ctx,
                "TemplateDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let instantiation = addAnalysisTestType(
                ctx,
                "Instantiation",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    definition,
                    [pointer],
                    ctx.translationUnit.cursor(),
                    None
                ))
            )
            let ids = [integer, pointer, definition, instantiation]

            @Expect(deriveTestResult(ctx, ids, definition, DeriveTrait.Default), CanDerive.Yes)
            @Expect(deriveTestResult(ctx, ids, pointer, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, instantiation, DeriveTrait.Default), CanDerive.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func opaqueTemplateDefinitionMakesInstantiationTriviallyDerivable(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(ctx, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(integer))
            let opaqueDefinition = addAnalysisTestType(ctx, "OpaqueDefinition", TypeKind.TypeKindOpaque)
            let instantiation = addAnalysisTestType(
                ctx,
                "OpaqueInstantiation",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    opaqueDefinition,
                    [pointer],
                    ctx.translationUnit.cursor(),
                    None
                ))
            )
            let ids = [integer, pointer, opaqueDefinition, instantiation]

            @Expect(deriveTestResult(ctx, ids, pointer, DeriveTrait.Default), CanDerive.No)
            @Expect(deriveTestResult(ctx, ids, instantiation, DeriveTrait.Default), CanDerive.Yes)
        } finally {
            ctx.close()
        }
    }
}
