package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class SizednessAnalysisRulesTest {
    @TestCase
    func distinguishesEmptyDependentAndConcreteRecords(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addDeriveTestTypeWithLayout(
                ctx,
                "Integer",
                Layout(4, 4),
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let empty = addAnalysisTestType(
                ctx,
                "Empty",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let concrete = addAnalysisTestType(
                ctx,
                "Concrete",
                TypeKind.TypeKindComp(analysisTestRecord([integer]))
            )
            let dependentComp = analysisTestRecord(Array<TypeId>())
            dependentComp.baseMembers.add(Base(parameter, BaseKind.Normal, "base", true))
            let dependent = addAnalysisTestType(ctx, "Dependent", TypeKind.TypeKindComp(dependentComp))
            let items = analysisTestItems([integer, parameter, empty, concrete, dependent])
            let vtables = computeHasVtable(ctx, items)
            let results = computeSizedness(ctx, items, vtables)

            @Expect(sizednessResultFor(results, empty), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, parameter), SizednessResult.DependsOnTypeParam)
            @Expect(sizednessResultFor(results, concrete), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, dependent), SizednessResult.DependsOnTypeParam)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func arraysVtablesAndOpaqueLayoutsUseTheirDedicatedRules(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let emptyArray = addAnalysisTestType(ctx, "EmptyArray", TypeKind.TypeKindArray(parameter, 0))
            let populatedArray = addAnalysisTestType(ctx, "PopulatedArray", TypeKind.TypeKindArray(parameter, 3))
            let virtualComp = analysisTestRecord(Array<TypeId>())
            virtualComp.hasOwnVirtualMethod = true
            let virtualRecord = addAnalysisTestType(ctx, "VirtualRecord", TypeKind.TypeKindComp(virtualComp))
            let opaqueComp = analysisTestRecord(Array<TypeId>())
            opaqueComp.hasNonTypeTemplateParams = true
            let opaqueRecord = addDeriveTestTypeWithLayout(
                ctx,
                "OpaqueRecord",
                Layout(16, 8),
                TypeKind.TypeKindComp(opaqueComp)
            )
            let packedComp = analysisTestRecord(Array<TypeId>())
            packedComp.packedAttr = true
            let packedRecord = addDeriveTestTypeWithLayout(
                ctx,
                "PackedRecord",
                Layout(4, 1),
                TypeKind.TypeKindComp(packedComp)
            )
            let items = analysisTestItems([
                parameter, emptyArray, populatedArray, virtualRecord, opaqueRecord, packedRecord
            ])
            let vtables = computeHasVtable(ctx, items)
            let results = computeSizedness(ctx, items, vtables)

            @Expect(sizednessResultFor(results, emptyArray), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, populatedArray), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, virtualRecord), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, opaqueRecord), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, packedRecord), SizednessResult.NonZeroSized)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class HasVtableAnalysisRulesTest {
    @TestCase
    func distinguishesOwnInheritedAliasAndTemplateVtables(): Unit {
        let ctx = analysisTestContext()
        try {
            let baseComp = analysisTestRecord(Array<TypeId>())
            baseComp.hasOwnVirtualMethod = true
            let base = addAnalysisTestType(ctx, "Base", TypeKind.TypeKindComp(baseComp))
            let alias = addAnalysisTestType(ctx, "BaseAlias", TypeKind.TypeKindAlias(base))
            let derivedComp = analysisTestRecord(Array<TypeId>())
            derivedComp.baseMembers.add(Base(alias, BaseKind.Normal, "base", true))
            let derived = addAnalysisTestType(ctx, "Derived", TypeKind.TypeKindComp(derivedComp))
            let argument = addAnalysisTestType(
                ctx,
                "Argument",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let instantiation = addAnalysisTestType(
                ctx,
                "BaseInt",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    base,
                    [argument],
                    ctx.translationUnit.cursor(),
                    None
                ))
            )
            let items = analysisTestItems([base, alias, derived, argument, instantiation])
            let results = computeHasVtable(ctx, items)

            @Expect(hasVtableResultFor(results, base), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, alias), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, derived), HasVtableResult.BaseHasVtable)
            @Expect(hasVtableResultFor(results, instantiation), HasVtableResult.SelfHasVtable)
            @Expect(analysisHasVtablePointer(results, derived), false)
        } finally {
            ctx.close()
        }
    }
}
