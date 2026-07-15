package cjbind.ir.analysis

import cjbind.ir.*
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

func analysisTestContext(): CjbindContext {
    let options = CjbindOptions()
    options.clangArgs.add(all: [
        "-x", "c++", "-std=c++14", "cjbind/src/ir/analysis_test_input.hpp"
    ])
    return CjbindContext(options)
}

func addAnalysisTestType(ctx: CjbindContext, name: String, kind: TypeKind): TypeId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(id, None, ctx.rootModule, ItemKind.KindType(Type(Some(name), None, kind, false)), None),
        None,
        None
    )
    return id
}

func addAnalysisTestTypeWithLayout(
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

func analysisTestRecord(fields: Array<TypeId>): CompInfo {
    let comp = CompInfo(CompKind.CompKindStruct, isCxxRecord: true)
    let members = ArrayList<Field>()
    for (fieldType in fields) {
        members.add(Field.DataMember(RawField(None, fieldType, None, None, None)))
    }
    comp.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(members.toArray(), false))
    return comp
}

func analysisTestItems(ids: Array<ItemId>): ItemSet {
    return ItemSet(ids)
}

@Test
public class UsedTemplateParametersPropagationTest {
    @TestCase
    func mapsOnlyUsedArgumentsAndTreatsExcludedDefinitionsConservatively(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let argument = addAnalysisTestType(ctx, "U", TypeKind.TypeKindTypeParam)

            let unusedComp = analysisTestRecord(Array<TypeId>())
            unusedComp.templateParams.add(parameter)
            let unusedDefinition = addAnalysisTestType(ctx, "Unused", TypeKind.TypeKindComp(unusedComp))
            let unusedInstantiation = addAnalysisTestType(
                ctx,
                "UnusedU",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    unusedDefinition,
                    [argument]
                ))
            )

            let usedComp = analysisTestRecord([parameter])
            usedComp.templateParams.add(parameter)
            let usedDefinition = addAnalysisTestType(ctx, "Used", TypeKind.TypeKindComp(usedComp))
            let usedInstantiation = addAnalysisTestType(
                ctx,
                "UsedU",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    usedDefinition,
                    [argument]
                ))
            )

            let allowlisted = analysisTestItems([
                parameter, argument, unusedDefinition, unusedInstantiation, usedDefinition, usedInstantiation
            ])
            let used = analyzeUsedTemplateParameters(ctx, allowlisted)
            @Expect(used.get(unusedInstantiation).getOrThrow().contains(argument), false)
            @Expect(used.get(usedInstantiation).getOrThrow().contains(argument), true)

            let excludedDefinition = analyzeUsedTemplateParameters(
                ctx,
                analysisTestItems([unusedInstantiation])
            )
            @Expect(excludedDefinition.get(unusedInstantiation).getOrThrow().contains(argument), true)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class AnalysisDomainBoundaryTest {
    @TestCase
    func vtableFactsDoNotCrossExcludedTypes(): Unit {
        let ctx = analysisTestContext()
        try {
            let baseComp = analysisTestRecord(Array<TypeId>())
            baseComp.hasOwnVirtualMethod = true
            let base = addAnalysisTestType(ctx, "Base", TypeKind.TypeKindComp(baseComp))
            let excludedComp = analysisTestRecord(Array<TypeId>())
            excludedComp.baseMembers.add(Base(base, BaseKind.Normal, "base", true))
            let excluded = addAnalysisTestType(ctx, "Excluded", TypeKind.TypeKindComp(excludedComp))
            let outerComp = analysisTestRecord(Array<TypeId>())
            outerComp.baseMembers.add(Base(excluded, BaseKind.Normal, "base", true))
            let outer = addAnalysisTestType(ctx, "Outer", TypeKind.TypeKindComp(outerComp))

            let results = computeHasVtable(ctx, analysisTestItems([base, outer]))
            @Expect(hasVtableResultFor(results, base), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, excluded), HasVtableResult.No)
            @Expect(hasVtableResultFor(results, outer), HasVtableResult.No)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func sizednessFactsDoNotCrossExcludedTypes(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let excludedComp = analysisTestRecord(Array<TypeId>())
            excludedComp.baseMembers.add(Base(parameter, BaseKind.Normal, "base", true))
            let excluded = addAnalysisTestType(ctx, "Excluded", TypeKind.TypeKindComp(excludedComp))
            let outerComp = analysisTestRecord(Array<TypeId>())
            outerComp.baseMembers.add(Base(excluded, BaseKind.Normal, "base", true))
            let outer = addAnalysisTestType(ctx, "Outer", TypeKind.TypeKindComp(outerComp))
            let items = analysisTestItems([parameter, outer])
            let results = computeSizedness(ctx, items, computeHasVtable(ctx, items))

            @Expect(sizednessResultFor(results, parameter), SizednessResult.DependsOnTypeParam)
            @Expect(sizednessResultFor(results, excluded), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, outer), SizednessResult.ZeroSized)
        } finally {
            ctx.close()
        }
    }
}
