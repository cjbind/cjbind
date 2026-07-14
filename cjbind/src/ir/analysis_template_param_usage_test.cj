package cjbind.ir

import std.collection.HashMap
import std.unittest.*
import std.unittest.testmacro.*

func addUsageTypeAt(
    ctx: CjbindContext,
    id: ItemId,
    parent: ItemId,
    name: String,
    kind: TypeKind
): TypeId {
    ctx.addItem(
        Item(id, None, parent, ItemKind.KindType(Type(Some(name), None, kind, false)), None),
        None,
        None
    )
    return id
}

func addUsageType(
    ctx: CjbindContext,
    parent: ItemId,
    name: String,
    kind: TypeKind
): TypeId {
    let id = ctx.nextItemId()
    return addUsageTypeAt(ctx, id, parent, name, kind)
}

func addUsageVar(ctx: CjbindContext, parent: ItemId, name: String, ty: TypeId): ItemId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(id, None, parent, ItemKind.KindVar(Var(name, ty, None, false)), None),
        None,
        None
    )
    return id
}

func usageResults(ctx: CjbindContext, ids: Array<ItemId>): HashMap<ItemId, ItemSet> {
    return analyzeUsedTemplateParameters(ctx, analysisTestItems(ids))
}

func expectParameterUsage(
    results: HashMap<ItemId, ItemSet>,
    item: ItemId,
    parameter: TypeId,
    expected: Bool
): Unit {
    @Expect(results.get(item).getOrThrow().contains(parameter), expected)
}

func addCrtpUsageGraph(
    ctx: CjbindContext,
    baseUsesParameter: Bool,
    derivedUsesParameter: Bool
): (Array<ItemId>, ItemId, TypeId) {
    let integer = addUsageType(
        ctx,
        ctx.rootModule,
        "Integer",
        TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
    )
    let baseParameter = addUsageType(ctx, ctx.rootModule, "T", TypeKind.TypeKindTypeParam)
    let baseComp = if (baseUsesParameter) {
        let pointer = addUsageType(ctx, ctx.rootModule, "TPointer", TypeKind.TypeKindPointer(baseParameter))
        analysisTestRecord([pointer])
    } else {
        analysisTestRecord([integer])
    }
    baseComp.templateParams.add(baseParameter)
    let baseDefinition = addUsageType(ctx, ctx.rootModule, "Base", TypeKind.TypeKindComp(baseComp))

    let derivedParameter = addUsageType(ctx, ctx.rootModule, "U", TypeKind.TypeKindTypeParam)
    let derivedDefinition = ctx.nextItemId()
    let selfInstantiation = addUsageType(
        ctx,
        ctx.rootModule,
        "DerivedU",
        TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
            derivedDefinition,
            [derivedParameter],
            ctx.translationUnit.cursor(),
            None
        ))
    )
    let baseInstantiation = addUsageType(
        ctx,
        ctx.rootModule,
        "BaseDerivedU",
        TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
            baseDefinition,
            [selfInstantiation],
            ctx.translationUnit.cursor(),
            None
        ))
    )
    let fields = if (derivedUsesParameter) { [derivedParameter] } else { [integer] }
    let derivedComp = analysisTestRecord(fields)
    derivedComp.templateParams.add(derivedParameter)
    derivedComp.baseMembers.add(Base(baseInstantiation, BaseKind.Normal, "base", true))
    addUsageTypeAt(ctx, derivedDefinition, ctx.rootModule, "Derived", TypeKind.TypeKindComp(derivedComp))

    return (
        [
            integer,
            baseParameter,
            baseDefinition,
            derivedParameter,
            selfInstantiation,
            baseInstantiation,
            derivedDefinition
        ],
        derivedDefinition,
        derivedParameter
    )
}

@Test
public class UsedTemplateParameterBranchTest {
    @TestCase
    func usage0DirectFieldUsesTheParameter(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addUsageType(ctx, ctx.rootModule, "T", TypeKind.TypeKindTypeParam)
            let comp = analysisTestRecord([parameter])
            comp.templateParams.add(parameter)
            let definition = addUsageType(ctx, ctx.rootModule, "Uses", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [parameter, definition])
            expectParameterUsage(results, definition, parameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage1UnusedParameterIsRemoved(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addUsageType(ctx, ctx.rootModule, "T", TypeKind.TypeKindTypeParam)
            let comp = analysisTestRecord(Array<TypeId>())
            comp.templateParams.add(parameter)
            let definition = addUsageType(ctx, ctx.rootModule, "Unused", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [parameter, definition])
            expectParameterUsage(results, definition, parameter, false)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage2NestedTypeKeepsOuterParameterUsageSeparate(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let parameter = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let inner = addUsageType(
                ctx,
                outer,
                "Inner",
                TypeKind.TypeKindComp(analysisTestRecord([parameter]))
            )
            let outerComp = analysisTestRecord([parameter])
            outerComp.templateParams.add(parameter)
            outerComp.innerTypes.add(inner)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(outerComp))
            let results = usageResults(ctx, [outer, parameter, inner])
            expectParameterUsage(results, outer, parameter, true)
            expectParameterUsage(results, inner, parameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage3NestedTemplateUsesOuterAndInnerParameters(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let outerParameter = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let inner = ctx.nextItemId()
            let innerParameter = addUsageType(ctx, inner, "U", TypeKind.TypeKindTypeParam)
            let innerComp = analysisTestRecord([outerParameter, innerParameter])
            innerComp.templateParams.add(innerParameter)
            addUsageTypeAt(ctx, inner, outer, "Inner", TypeKind.TypeKindComp(innerComp))
            let outerComp = analysisTestRecord([outerParameter])
            outerComp.templateParams.add(outerParameter)
            outerComp.innerTypes.add(inner)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(outerComp))
            let results = usageResults(ctx, [outer, outerParameter, inner, innerParameter])
            expectParameterUsage(results, outer, outerParameter, true)
            expectParameterUsage(results, inner, outerParameter, true)
            expectParameterUsage(results, inner, innerParameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage4NestedTemplateCanDiscardBothParameters(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addUsageType(ctx, ctx.rootModule, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let outer = ctx.nextItemId()
            let outerParameter = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let inner = ctx.nextItemId()
            let innerParameter = addUsageType(ctx, inner, "U", TypeKind.TypeKindTypeParam)
            let innerComp = analysisTestRecord([integer])
            innerComp.templateParams.add(innerParameter)
            addUsageTypeAt(ctx, inner, outer, "Inner", TypeKind.TypeKindComp(innerComp))
            let outerComp = analysisTestRecord([outerParameter])
            outerComp.templateParams.add(outerParameter)
            outerComp.innerTypes.add(inner)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(outerComp))
            let results = usageResults(ctx, [integer, outer, outerParameter, inner, innerParameter])
            expectParameterUsage(results, inner, outerParameter, false)
            expectParameterUsage(results, inner, innerParameter, false)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage5AliasFieldUsesItsTargetParameter(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let parameter = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let alias = addUsageType(ctx, outer, "Alias", TypeKind.TypeKindAlias(parameter))
            let comp = analysisTestRecord([alias])
            comp.templateParams.add(parameter)
            comp.innerTypes.add(alias)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [outer, parameter, alias])
            expectParameterUsage(results, outer, parameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage6UnusedAliasDoesNotMakeTheRecordGeneric(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addUsageType(ctx, ctx.rootModule, "Integer", TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt))
            let outer = ctx.nextItemId()
            let parameter = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let alias = addUsageType(ctx, outer, "Alias", TypeKind.TypeKindAlias(parameter))
            let comp = analysisTestRecord([integer])
            comp.templateParams.add(parameter)
            comp.innerTypes.add(alias)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [integer, outer, parameter, alias])
            expectParameterUsage(results, outer, parameter, false)
            expectParameterUsage(results, alias, parameter, true)
            ctx.usedTemplateParameters = Some(results)
            let aliasParameters = ctx.usedTemplateParams(alias)
            @Expect(aliasParameters.size, 1)
            @Expect(aliasParameters[0], parameter)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage7MiddleParameterCanBeRemovedIndependently(): Unit {
        let ctx = analysisTestContext()
        try {
            let first = addUsageType(ctx, ctx.rootModule, "T", TypeKind.TypeKindTypeParam)
            let middle = addUsageType(ctx, ctx.rootModule, "U", TypeKind.TypeKindTypeParam)
            let last = addUsageType(ctx, ctx.rootModule, "V", TypeKind.TypeKindTypeParam)
            let comp = analysisTestRecord([first, last])
            comp.templateParams.add(first)
            comp.templateParams.add(middle)
            comp.templateParams.add(last)
            let definition = addUsageType(ctx, ctx.rootModule, "SkipMiddle", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [first, middle, last, definition])
            expectParameterUsage(results, definition, first, true)
            expectParameterUsage(results, definition, middle, false)
            expectParameterUsage(results, definition, last, true)
            ctx.usedTemplateParameters = Some(results)
            let orderedParameters = ctx.usedTemplateParams(definition)
            @Expect(orderedParameters.size, 2)
            @Expect(orderedParameters[0], first)
            @Expect(orderedParameters[1], last)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usedTemplateParamsExcludeParametersOutsideTheLexicalTemplate(): Unit {
        let ctx = analysisTestContext()
        try {
            let ownParameter = addUsageType(ctx, ctx.rootModule, "T", TypeKind.TypeKindTypeParam)
            let foreignParameter = addUsageType(ctx, ctx.rootModule, "Foreign", TypeKind.TypeKindTypeParam)
            let comp = analysisTestRecord([ownParameter])
            comp.templateParams.add(ownParameter)
            let definition = addUsageType(ctx, ctx.rootModule, "OwnsT", TypeKind.TypeKindComp(comp))

            let used = ItemSet()
            used.add(canonicalItemId(ctx, ownParameter))
            used.add(canonicalItemId(ctx, foreignParameter))
            let results = HashMap<ItemId, ItemSet>()
            results.add(definition, used)
            ctx.usedTemplateParameters = Some(results)

            let parameters = ctx.usedTemplateParams(definition)
            @Expect(parameters.size, 1)
            @Expect(parameters[0], ownParameter)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage8TypedefAndAliasFieldsUseBothParameters(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let first = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let second = addUsageType(ctx, outer, "U", TypeKind.TypeKindTypeParam)
            let firstAlias = addUsageType(ctx, outer, "First", TypeKind.TypeKindAlias(first))
            let secondAlias = addUsageType(ctx, outer, "Second", TypeKind.TypeKindAlias(second))
            let comp = analysisTestRecord([firstAlias, secondAlias])
            comp.templateParams.add(first)
            comp.templateParams.add(second)
            comp.innerTypes.add(firstAlias)
            comp.innerTypes.add(secondAlias)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Aliases", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [outer, first, second, firstAlias, secondAlias])
            expectParameterUsage(results, outer, first, true)
            expectParameterUsage(results, outer, second, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage9NestedAliasUseDoesNotLeakIntoOuterRecord(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let first = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let second = addUsageType(ctx, outer, "U", TypeKind.TypeKindTypeParam)
            let firstAlias = addUsageType(ctx, outer, "First", TypeKind.TypeKindAlias(first))
            let secondAlias = addUsageType(ctx, outer, "Second", TypeKind.TypeKindAlias(second))
            let inner = addUsageType(
                ctx,
                outer,
                "Inner",
                TypeKind.TypeKindComp(analysisTestRecord([firstAlias, secondAlias]))
            )
            let outerComp = analysisTestRecord(Array<TypeId>())
            outerComp.templateParams.add(first)
            outerComp.templateParams.add(second)
            outerComp.innerTypes.add(firstAlias)
            outerComp.innerTypes.add(secondAlias)
            outerComp.innerTypes.add(inner)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(outerComp))
            let results = usageResults(ctx, [outer, first, second, firstAlias, secondAlias, inner])
            expectParameterUsage(results, outer, first, false)
            expectParameterUsage(results, outer, second, false)
            expectParameterUsage(results, inner, first, true)
            expectParameterUsage(results, inner, second, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage10NestedFieldPropagatesTwoParametersButNotTheThird(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let first = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let second = addUsageType(ctx, outer, "U", TypeKind.TypeKindTypeParam)
            let never = addUsageType(ctx, outer, "Never", TypeKind.TypeKindTypeParam)
            let firstAlias = addUsageType(ctx, outer, "First", TypeKind.TypeKindAlias(first))
            let secondAlias = addUsageType(ctx, outer, "Second", TypeKind.TypeKindAlias(second))
            let inner = addUsageType(
                ctx,
                outer,
                "Inner",
                TypeKind.TypeKindComp(analysisTestRecord([firstAlias, secondAlias]))
            )
            let outerComp = analysisTestRecord([inner])
            outerComp.templateParams.add(first)
            outerComp.templateParams.add(second)
            outerComp.templateParams.add(never)
            outerComp.innerTypes.add(firstAlias)
            outerComp.innerTypes.add(secondAlias)
            outerComp.innerTypes.add(inner)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(outerComp))
            let results = usageResults(ctx, [outer, first, second, never, firstAlias, secondAlias, inner])
            expectParameterUsage(results, outer, first, true)
            expectParameterUsage(results, outer, second, true)
            expectParameterUsage(results, outer, never, false)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage11StaticMemberDoesNotAffectRecordLayoutParameters(): Unit {
        let ctx = analysisTestContext()
        try {
            let outer = ctx.nextItemId()
            let parameter = addUsageType(ctx, outer, "T", TypeKind.TypeKindTypeParam)
            let staticMember = addUsageVar(ctx, outer, "staticMember", parameter)
            let comp = analysisTestRecord(Array<TypeId>())
            comp.templateParams.add(parameter)
            comp.innerVars.add(staticMember)
            addUsageTypeAt(ctx, outer, ctx.rootModule, "Outer", TypeKind.TypeKindComp(comp))
            let results = usageResults(ctx, [outer, parameter, staticMember])
            expectParameterUsage(results, outer, parameter, false)
            expectParameterUsage(results, staticMember, parameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage12CrtpBaseAndDerivedBothUseTheParameter(): Unit {
        let ctx = analysisTestContext()
        try {
            let (items, definition, parameter) = addCrtpUsageGraph(ctx, true, true)
            let results = usageResults(ctx, items)
            expectParameterUsage(results, definition, parameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage13DerivedFieldUsesParameterEvenWhenCrtpBaseDoesNot(): Unit {
        let ctx = analysisTestContext()
        try {
            let (items, definition, parameter) = addCrtpUsageGraph(ctx, false, true)
            let results = usageResults(ctx, items)
            expectParameterUsage(results, definition, parameter, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage14UnusedCrtpParameterStaysUnusedWhenBaseIgnoresIt(): Unit {
        let ctx = analysisTestContext()
        try {
            let (items, definition, parameter) = addCrtpUsageGraph(ctx, false, false)
            let results = usageResults(ctx, items)
            expectParameterUsage(results, definition, parameter, false)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage15RecursiveCrtpDependencyDoesNotCreateUsageFromNothing(): Unit {
        let ctx = analysisTestContext()
        try {
            let (items, definition, parameter) = addCrtpUsageGraph(ctx, true, false)
            let results = usageResults(ctx, items)
            expectParameterUsage(results, definition, parameter, false)
        } finally {
            ctx.close()
        }
    }
}
