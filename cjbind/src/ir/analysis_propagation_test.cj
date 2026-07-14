package cjbind.ir

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
public class DestructorPropagationTest {
    @TestCase
    func propagatesThroughAliasesFieldsAndTemplateArgumentsButNotUnionFields(): Unit {
        let ctx = analysisTestContext()
        try {
            let leafComp = analysisTestRecord(Array<TypeId>())
            leafComp.hasDestructor = true
            let leaf = addAnalysisTestType(ctx, "Leaf", TypeKind.TypeKindComp(leafComp))
            let alias = addAnalysisTestType(ctx, "LeafAlias", TypeKind.TypeKindAlias(leaf))
            let holder = addAnalysisTestType(ctx, "Holder", TypeKind.TypeKindComp(analysisTestRecord([alias])))

            let unionComp = CompInfo(CompKind.CompKindUnion, isCxxRecord: true)
            unionComp.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(
                [Field.DataMember(RawField(None, leaf, None, None, None))],
                false
            ))
            let union = addAnalysisTestType(ctx, "Choice", TypeKind.TypeKindComp(unionComp))
            let instantiation = addAnalysisTestType(
                ctx,
                "BoxLeaf",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    holder,
                    [leaf]
                ))
            )

            let results = analyzeHasDestructor(ctx, analysisTestItems([leaf, alias, holder, union, instantiation]))
            @Expect(results.contains(alias), true)
            @Expect(results.contains(holder), true)
            @Expect(results.contains(instantiation), true)
            @Expect(results.contains(union), false)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class TypeParameterArrayPropagationTest {
    @TestCase
    func followsCanonicalArrayElementsAliasesFieldsBasesAndTemplates(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let parameterAlias = addAnalysisTestType(ctx, "TAlias", TypeKind.TypeKindAlias(parameter))
            let array = addAnalysisTestType(ctx, "TArray", TypeKind.TypeKindArray(parameterAlias, 4))
            let alias = addAnalysisTestType(ctx, "ArrayAlias", TypeKind.TypeKindAlias(array))
            let holderComp = analysisTestRecord([alias])
            let holder = addAnalysisTestType(ctx, "Holder", TypeKind.TypeKindComp(holderComp))
            let derivedComp = analysisTestRecord(Array<TypeId>())
            derivedComp.baseMembers.add(Base(holder, BaseKind.Normal, "base", true))
            let derived = addAnalysisTestType(ctx, "Derived", TypeKind.TypeKindComp(derivedComp))
            let pointer = addAnalysisTestType(ctx, "TPointer", TypeKind.TypeKindPointer(parameter))
            let instantiation = addAnalysisTestType(
                ctx,
                "TemplateArray",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    pointer,
                    [array]
                ))
            )

            let results = analyzeHasTypeParameterInArray(
                ctx,
                analysisTestItems([parameter, parameterAlias, array, alias, holder, derived, pointer, instantiation])
            )
            @Expect(results.contains(array), true)
            @Expect(results.contains(alias), true)
            @Expect(results.contains(holder), true)
            @Expect(results.contains(derived), true)
            @Expect(results.contains(instantiation), true)
            @Expect(results.contains(pointer), false)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class FloatPropagationTest {
    @TestCase
    func propagatesThroughContainersRecordsBasesAndTemplatesButNotPointers(): Unit {
        let ctx = analysisTestContext()
        try {
            let scalar = addAnalysisTestType(
                ctx,
                "Float",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindFloat)
            )
            let array = addAnalysisTestType(ctx, "FloatArray", TypeKind.TypeKindArray(scalar, 2))
            let vector = addAnalysisTestType(ctx, "FloatVector", TypeKind.TypeKindVector(scalar, 4))
            let alias = addAnalysisTestType(ctx, "FloatAlias", TypeKind.TypeKindAlias(array))
            let holder = addAnalysisTestType(ctx, "Holder", TypeKind.TypeKindComp(analysisTestRecord([alias])))
            let derivedComp = analysisTestRecord(Array<TypeId>())
            derivedComp.baseMembers.add(Base(holder, BaseKind.Normal, "base", true))
            let derived = addAnalysisTestType(ctx, "Derived", TypeKind.TypeKindComp(derivedComp))
            let pointer = addAnalysisTestType(ctx, "FloatPointer", TypeKind.TypeKindPointer(scalar))
            let instantiation = addAnalysisTestType(
                ctx,
                "TemplateFloat",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    pointer,
                    [vector]
                ))
            )

            let results = analyzeHasFloat(
                ctx,
                analysisTestItems([scalar, array, vector, alias, holder, derived, pointer, instantiation])
            )
            @Expect(results.contains(array), true)
            @Expect(results.contains(vector), true)
            @Expect(results.contains(alias), true)
            @Expect(results.contains(holder), true)
            @Expect(results.contains(derived), true)
            @Expect(results.contains(instantiation), true)
            @Expect(results.contains(pointer), false)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class AnalysisDomainBoundaryTest {
    @TestCase
    func floatFactsDoNotCrossExcludedTypes(): Unit {
        let ctx = analysisTestContext()
        try {
            let scalar = addAnalysisTestType(
                ctx,
                "Float",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindFloat)
            )
            let excluded = addAnalysisTestType(
                ctx,
                "Excluded",
                TypeKind.TypeKindComp(analysisTestRecord([scalar]))
            )
            let outer = addAnalysisTestType(
                ctx,
                "Outer",
                TypeKind.TypeKindComp(analysisTestRecord([excluded]))
            )

            let results = analyzeHasFloat(ctx, analysisTestItems([scalar, outer]))
            @Expect(results.contains(scalar), true)
            @Expect(results.contains(excluded), false)
            @Expect(results.contains(outer), false)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func destructorFactsDoNotCrossExcludedTypes(): Unit {
        let ctx = analysisTestContext()
        try {
            let leafComp = analysisTestRecord(Array<TypeId>())
            leafComp.hasDestructor = true
            let leaf = addAnalysisTestType(ctx, "Leaf", TypeKind.TypeKindComp(leafComp))
            let excluded = addAnalysisTestType(
                ctx,
                "Excluded",
                TypeKind.TypeKindComp(analysisTestRecord([leaf]))
            )
            let outer = addAnalysisTestType(
                ctx,
                "Outer",
                TypeKind.TypeKindComp(analysisTestRecord([excluded]))
            )

            let results = analyzeHasDestructor(ctx, analysisTestItems([leaf, outer]))
            @Expect(results.contains(leaf), true)
            @Expect(results.contains(excluded), false)
            @Expect(results.contains(outer), false)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func arrayParameterFactsDoNotCrossExcludedTypes(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let array = addAnalysisTestType(ctx, "Values", TypeKind.TypeKindArray(parameter, 4))
            let excluded = addAnalysisTestType(
                ctx,
                "Excluded",
                TypeKind.TypeKindComp(analysisTestRecord([array]))
            )
            let outer = addAnalysisTestType(
                ctx,
                "Outer",
                TypeKind.TypeKindComp(analysisTestRecord([excluded]))
            )

            let results = analyzeHasTypeParameterInArray(
                ctx,
                analysisTestItems([parameter, array, outer])
            )
            @Expect(results.contains(array), true)
            @Expect(results.contains(excluded), false)
            @Expect(results.contains(outer), false)
        } finally {
            ctx.close()
        }
    }

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
