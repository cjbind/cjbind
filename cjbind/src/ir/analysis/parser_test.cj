package cjbind.ir.analysis

import cjbind.ir.*
import cjbind.clang
import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

func parseAnalysisTestCursor(
    ctx: CjbindContext,
    cursor: clang.Cursor,
    parent: ?ItemId
): Unit {
    if (cursor.isBuiltin() || cursor.isInSystemHeader()) {
        return
    }
    match (Item.parse(cursor, parent, ctx)) {
        case Ok(_) => ()
        case Err(ParseError.Continue) => ()
        case Err(ParseError.Recurse) => cursor.visitContinue {
            child => parseAnalysisTestCursor(ctx, child, parent)
        }
    }
}

func parsedAnalysisTestContext(header: String): CjbindContext {
    let options = CjbindOptions()
    options.headers.add(header)
    options.clangArgs.add(all: ["-x", "c++", "-std=c++14", header])
    let ctx = CjbindContext(options)
    ctx.translationUnit.cursor().visitContinue {
        child => parseAnalysisTestCursor(ctx, child, None)
    }
    ctx.resolveTypeRefs()
    ctx.computeBitfieldUnits()
    let items = ItemSet()
    for ((id, _) in ctx.getItems()) {
        items.add(id)
    }
    ctx.installAnalysisResults(AnalysisResults(analyzeUsedTemplateParameters(ctx, items)))
    return ctx
}

func namedType(ctx: CjbindContext, name: String): TypeId {
    for ((id, item) in ctx.getItems()) {
        if (let Some(ty) <- item.asType()) {
            if (ty.name == Some(name)) {
                return id
            }
        }
    }
    throw Exception("missing parsed type ${name}")
}

func nestedType(ctx: CjbindContext, parent: ItemId, name: String): TypeId {
    for ((id, item) in ctx.getItems()) {
        if (item.parentId == parent) {
            if (let Some(ty) <- item.asType()) {
                if (ty.name == Some(name)) {
                    return id
                }
            }
        }
    }
    throw Exception("missing parsed nested type ${name}")
}

func recordInfo(ctx: CjbindContext, id: TypeId): CompInfo {
    return match (ctx.resolveType(id).kind) {
        case TypeKind.TypeKindComp(comp) => comp
        case _ => throw Exception("parsed type is not a record")
    }
}

func fieldType(ctx: CjbindContext, record: TypeId, name: String): TypeId {
    let fields = recordInfo(ctx, record).fields
    match (fields) {
        case CompFields.CompFieldsBefore(rawFields) =>
            for (field in rawFields) {
                if (field.name == Some(name)) {
                    return field.ty
                }
            }
        case CompFields.CompFieldsAfter(value) =>
            for (field in value.fields) {
                if (let Field.DataMember(data) <- field) {
                    if (data.name == Some(name)) {
                        return data.ty
                    }
                }
            }
        case CompFields.CompFieldsError => ()
    }
    throw Exception("missing parsed field ${name}")
}

func referenceTarget(ctx: CjbindContext, id: TypeId): TypeId {
    return match (ctx.resolveType(id).kind) {
        case TypeKind.TypeKindReference(inner) => inner
        case TypeKind.ResolvedTypeRef(inner) => referenceTarget(ctx, inner)
        case _ => throw Exception("parsed type is not a reference")
    }
}

func pointerTarget(ctx: CjbindContext, id: TypeId): TypeId {
    return match (ctx.resolveType(id).kind) {
        case TypeKind.TypeKindPointer(inner) => inner
        case TypeKind.ResolvedTypeRef(inner) => pointerTarget(ctx, inner)
        case _ => throw Exception("parsed type is not a pointer")
    }
}

func aliasTarget(ctx: CjbindContext, id: TypeId): TypeId {
    return match (ctx.resolveType(id).kind) {
        case TypeKind.TypeKindAlias(inner) => inner
        case TypeKind.TypeKindTemplateAlias(inner, _) => inner
        case TypeKind.ResolvedTypeRef(inner) => aliasTarget(ctx, inner)
        case _ => throw Exception("parsed type is not an alias")
    }
}

func templateInstantiation(ctx: CjbindContext, id: TypeId): TemplateInstantiation {
    return match (ctx.resolveType(id).kind) {
        case TypeKind.TypeKindTemplateInstantiation(instantiation) => instantiation
        case TypeKind.ResolvedTypeRef(inner) => templateInstantiation(ctx, inner)
        case TypeKind.TypeKindAlias(inner) => templateInstantiation(ctx, inner)
        case TypeKind.TypeKindTemplateAlias(inner, _) => templateInstantiation(ctx, inner)
        case TypeKind.TypeKindComp(_) => throw Exception("parsed template use is a record")
        case TypeKind.TypeKindOpaque => throw Exception("parsed template use is opaque")
        case TypeKind.TypeKindTypeParam => throw Exception("parsed template use is a type parameter")
        case TypeKind.TypeKindPointer(_) => throw Exception("parsed template use is a pointer")
        case TypeKind.TypeKindReference(_) => throw Exception("parsed template use is a reference")
        case _ => throw Exception("parsed type is not a template instantiation")
    }
}

func concreteTemplateFieldType(
    instantiation: TemplateInstantiation,
    name: String
): TypeId {
    let concrete = instantiation.concrete.getOrThrow({=>
        Exception("template instantiation has no concrete record")
    })
    match (concrete.fields) {
        case CompFields.CompFieldsBefore(rawFields) =>
            for (field in rawFields) {
                if (field.name == Some(name)) {
                    return field.ty
                }
            }
        case CompFields.CompFieldsAfter(value) =>
            for (field in value.fields) {
                if (let Field.DataMember(data) <- field) {
                    if (data.name == Some(name)) {
                        return data.ty
                    }
                }
            }
        case CompFields.CompFieldsError => ()
    }
    throw Exception("missing concrete template field ${name}")
}

func functionSignature(ctx: CjbindContext, name: String): FunctionSig {
    for ((_, item) in ctx.getItems()) {
        if (let ItemKind.KindFunction(function) <- item.kind) {
            if (function.name == name) {
                return match (ctx.resolveType(function.signature).kind) {
                    case TypeKind.TypeKindFunction(signature) => signature
                    case _ => throw Exception("parsed signature is not a function type")
                }
            }
        }
    }
    throw Exception("missing parsed function ${name}")
}

func expectUsedParameters(
    ctx: CjbindContext,
    item: ItemId,
    expected: Array<TypeId>
): Unit {
    let actual = ctx.usedTemplateParams(item)
    @Expect(actual.size, expected.size)
    for (parameter in expected) {
        @Expect(actual.contains(parameter), true)
    }
}

func testHeader(name: String): String {
    return "cjbind_test/testdata/headers/${name}.hpp"
}

@Test
public class ParsedReferenceIrTest {
    @TestCase
    func preservesReferenceAndPointerNesting(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("support/ir/references"))
        try {
            let container = namedType(ctx, "Container")
            let normalPointer = pointerTarget(ctx, fieldType(ctx, container, "normalPointer"))
            let constPointer = pointerTarget(ctx, fieldType(ctx, container, "constPointer"))
            let normalReference = referenceTarget(ctx, fieldType(ctx, container, "normalRef"))
            let constReference = referenceTarget(ctx, fieldType(ctx, container, "constRef"))
            let pointerReference = referenceTarget(ctx, fieldType(ctx, container, "pointerRef"))
            let constPointerReference = referenceTarget(
                ctx,
                fieldType(ctx, container, "constPointerRef")
            )

            @Expect(ctx.resolveType(normalPointer).isConst, false)
            @Expect(ctx.resolveType(constPointer).isConst, true)
            @Expect(ctx.resolveType(normalReference).isConst, false)
            @Expect(ctx.resolveType(constReference).isConst, true)
            @Expect(ctx.resolveType(pointerTarget(ctx, pointerReference)).isConst, false)
            @Expect(ctx.resolveType(pointerTarget(ctx, constPointerReference)).isConst, true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func preservesReferencesInFunctionSignatures(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("support/ir/references"))
        try {
            let returning = functionSignature(ctx, "refReturningFunction")
            referenceTarget(ctx, returning.returnType)

            let consuming = functionSignature(ctx, "functionConsumingRef")
            @Expect(consuming.argumentTypes.size, 3)
            referenceTarget(ctx, consuming.argumentTypes[0][1])
            referenceTarget(ctx, consuming.argumentTypes[2][1])

            let pointerConsuming = functionSignature(ctx, "functionConsumingPointerRef")
            pointerTarget(ctx, referenceTarget(ctx, pointerConsuming.argumentTypes[0][1]))
        } finally {
            ctx.close()
        }
    }
}

@Test
public class ParsedTemplateAliasIrTest {
    @TestCase
    func integralArgumentsKeepIdentityAndConcreteSpecializationFields(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("cxx-template"))
        try {
            let holder = namedType(ctx, "Holder")
            let fixed = templateInstantiation(ctx, fieldType(ctx, holder, "fixed"))
            @Expect(fixed.arguments.size, 0)
            @Expect(fixed.nonTypeArguments.size, 1)
            @Expect(fixed.nonTypeArguments[0].signedValue, 4)
            match (ctx.resolveType(concreteTemplateFieldType(fixed, "values")).kind) {
                case TypeKind.TypeKindArray(_, length) => @Expect(length, 4)
                case _ => @Assert(false)
            }

            let larger = templateInstantiation(ctx, fieldType(ctx, holder, "largerFixed"))
            @Expect(larger.nonTypeArguments[0].signedValue, 8)
            @Expect(
                fixed.nonTypeArguments[0].sameIdentity(larger.nonTypeArguments[0]),
                false
            )

            let negative = templateInstantiation(ctx, fieldType(ctx, holder, "negative"))
            @Expect(negative.nonTypeArguments[0].signedValue, -1)
            @Expect(negative.nonTypeArguments[0].disambiguatedName(), "minus_1")

            let escaped = templateInstantiation(ctx, fieldType(ctx, holder, "escaped"))
            @Expect(escaped.nonTypeArguments[0].signedValue, 10)

            let specialized = templateInstantiation(ctx, fieldType(ctx, holder, "specialized"))
            match (ctx.resolveType(concreteTemplateFieldType(specialized, "specialized")).kind) {
                case TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble) => ()
                case _ => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func functionPointerTypedefKeepsItsTemplateArgumentChain(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("support/ir/struct_with_typedef_template_arg"))
        try {
            let proxy = namedType(ctx, "Proxy")
            let parameters = selfTemplateParams(proxy, ctx)
            @Expect(parameters.size, 2)
            let alias = nestedType(ctx, proxy, "foo")
            let functionPointer = pointerTarget(ctx, aliasTarget(ctx, alias))
            let signature = match (ctx.resolveType(functionPointer).kind) {
                case TypeKind.TypeKindFunction(value) => value
                case _ => throw Exception("typedef target is not a function")
            }
            @Expect(signature.argumentTypes.size, 1)
            let argument = pointerTarget(ctx, signature.argumentTypes[0][1])
            @Expect(
                argument.intoResolver().throughTypeRefs().resolve(ctx).id,
                parameters[0]
            )
            expectUsedParameters(ctx, alias, [parameters[0]])
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func transitiveNestedTypedefUsesTheOuterParameter(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("template_typedef_transitive_param"))
        try {
            let wrapper = namedType(ctx, "Wrapper")
            let parameter = selfTemplateParams(wrapper, ctx)[0]
            let wrapped = nestedType(ctx, wrapper, "Wrapped")
            let alias = nestedType(ctx, wrapper, "Type")
            @Expect(
                fieldType(ctx, wrapped, "t").intoResolver().throughTypeRefs().resolve(ctx).id,
                parameter
            )
            @Expect(
                aliasTarget(ctx, alias).intoResolver().throughTypeRefs().resolve(ctx).id,
                wrapped
            )
            expectUsedParameters(ctx, wrapper, Array<TypeId>())
            expectUsedParameters(ctx, wrapped, [parameter])
            expectUsedParameters(ctx, alias, [parameter])
        } finally {
            ctx.close()
        }
    }
}

@Test
public class ParsedTemplateParameterAnalysisTest {
    @TestCase
    func anonymousTemplateParametersAreTrackedByPosition(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("anonymous-template-types"))
        try {
            let foo = namedType(ctx, "Foo")
            let fooParameters = selfTemplateParams(foo, ctx)
            @Expect(fooParameters.size, 2)
            expectUsedParameters(ctx, foo, [fooParameters[0]])

            let bar = namedType(ctx, "Bar")
            @Expect(selfTemplateParams(bar, ctx).size, 2)
            expectUsedParameters(ctx, bar, Array<TypeId>())

            let quux = namedType(ctx, "Quux")
            let quuxParameters = selfTemplateParams(quux, ctx)
            @Expect(quuxParameters.size, 2)
            expectUsedParameters(ctx, quux, [quuxParameters[1]])

            let lobo = namedType(ctx, "Lobo")
            @Expect(selfTemplateParams(lobo, ctx).size, 2)
            expectUsedParameters(ctx, lobo, Array<TypeId>())

            let alias = namedType(ctx, "AliasWithAnonType")
            @Expect(selfTemplateParams(alias, ctx).size, 1)
            expectUsedParameters(ctx, alias, Array<TypeId>())
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func nestedReferenceThroughTemplateAliasUsesBothOuterParameters(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("issue-1113-template-references"))
        try {
            let table = namedType(ctx, "nsBaseHashtable")
            let parameters = selfTemplateParams(table, ctx)
            @Expect(parameters.size, 2)
            let alias = nestedType(ctx, table, "EntryType")
            let entryPtr = nestedType(ctx, table, "EntryPtr")
            let entryUse = templateInstantiation(ctx, aliasTarget(ctx, alias))
            @Expect(entryUse.arguments.size, 2)
            @Expect(
                entryUse.arguments[0].intoResolver().throughTypeRefs().resolve(ctx).id,
                parameters[0]
            )
            @Expect(
                entryUse.arguments[1].intoResolver().throughTypeRefs().resolve(ctx).id,
                parameters[1]
            )
            let entryReference = referenceTarget(ctx, fieldType(ctx, entryPtr, "mEntry"))
            @Expect(
                entryReference.intoResolver().throughTypeRefs().resolve(ctx).id,
                alias
            )
            expectUsedParameters(ctx, table, Array<TypeId>())
            expectUsedParameters(ctx, alias, parameters)
            expectUsedParameters(ctx, entryPtr, parameters)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage2NestedRecordUsesTheOuterParameter(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("cxx-analysis-template-param-usage-2"))
        try {
            let outer = namedType(ctx, "UsesTemplateParameter")
            let parameter = selfTemplateParams(outer, ctx)[0]
            let inner = nestedType(ctx, outer, "AlsoUsesTemplateParameter")
            expectUsedParameters(ctx, outer, [parameter])
            expectUsedParameters(ctx, inner, [parameter])
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage3NestedTemplateUsesOuterAndInnerParameters(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("cxx-analysis-template-param-usage-3"))
        try {
            let outer = namedType(ctx, "UsesTemplateParameter")
            let outerParameter = selfTemplateParams(outer, ctx)[0]
            let inner = nestedType(ctx, outer, "AlsoUsesTemplateParameterAndMore")
            let innerParameter = selfTemplateParams(inner, ctx)[0]
            expectUsedParameters(ctx, inner, [outerParameter, innerParameter])
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage7FiltersOnlyTheUnusedMiddleArgument(): Unit {
        let ctx = parsedAnalysisTestContext(
            testHeader("cxx-analysis-template-param-usage-7")
        )
        try {
            let definition = namedType(ctx, "DoesNotUseU")
            let parameters = selfTemplateParams(definition, ctx)
            @Expect(parameters.size, 3)
            expectUsedParameters(ctx, definition, [parameters[0], parameters[2]])

            let alias = namedType(ctx, "Alias")
            let instantiation = templateInstantiation(ctx, aliasTarget(ctx, alias))
            @Expect(
                instantiation.definition
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                    .id,
                definition
            )
            @Expect(instantiation.arguments.size, 3)
            let codegenArguments = ctx.codegenTemplateArguments(
                definition,
                parameters,
                instantiation.arguments
            )
            @Expect(codegenArguments.size, 2)
            @Expect(codegenArguments[0], instantiation.arguments[0])
            @Expect(codegenArguments[1], instantiation.arguments[2])
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage10TransitiveNestedFieldUsesTwoParameters(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("cxx-analysis-template-param-usage-10"))
        try {
            let outer = namedType(ctx, "DoublyIndirectUsage")
            let parameters = selfTemplateParams(outer, ctx)
            @Expect(parameters.size, 3)
            let aliased = nestedType(ctx, outer, "Aliased")
            let typedefed = nestedType(ctx, outer, "Typedefed")
            let inner = nestedType(ctx, outer, "IndirectUsage")
            @Expect(
                aliasTarget(ctx, aliased).intoResolver().throughTypeRefs().resolve(ctx).id,
                parameters[0]
            )
            @Expect(
                aliasTarget(ctx, typedefed).intoResolver().throughTypeRefs().resolve(ctx).id,
                parameters[1]
            )
            expectUsedParameters(ctx, inner, [parameters[0], parameters[1]])
            expectUsedParameters(ctx, outer, [parameters[0], parameters[1]])
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage12CrtpBaseAndFieldUseTheDerivedParameter(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("cxx-analysis-template-param-usage-12"))
        try {
            let derived = namedType(ctx, "CrtpUsesU")
            let parameter = selfTemplateParams(derived, ctx)[0]
            let comp = recordInfo(ctx, derived)
            @Expect(comp.baseMembers.size, 1)
            let baseUse = templateInstantiation(ctx, comp.baseMembers[0].ty)
            @Expect(baseUse.arguments.size, 1)
            let base = baseUse.definition
            let baseParameter = selfTemplateParams(base, ctx)[0]
            let recursiveUse = templateInstantiation(ctx, baseUse.arguments[0])
            @Expect(recursiveUse.definition, derived)
            @Expect(recursiveUse.arguments.size, 1)
            @Expect(
                recursiveUse.arguments[0]
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                    .id,
                parameter
            )
            @Expect(
                pointerTarget(ctx, fieldType(ctx, base, "t"))
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                    .id,
                baseParameter
            )
            expectUsedParameters(ctx, base, [baseParameter])
            @Expect(
                fieldType(ctx, derived, "usage")
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                    .id,
                parameter
            )
            expectUsedParameters(ctx, derived, [parameter])
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func usage15RecursiveCrtpReferenceDoesNotCreateUsage(): Unit {
        let ctx = parsedAnalysisTestContext(testHeader("cxx-analysis-template-param-usage-15"))
        try {
            let derived = namedType(ctx, "CrtpIgnoresU")
            let parameter = selfTemplateParams(derived, ctx)[0]
            let comp = recordInfo(ctx, derived)
            @Expect(comp.baseMembers.size, 1)
            let baseUse = templateInstantiation(ctx, comp.baseMembers[0].ty)
            @Expect(baseUse.arguments.size, 1)
            let base = baseUse.definition
            let baseParameter = selfTemplateParams(base, ctx)[0]
            let recursiveUse = templateInstantiation(ctx, baseUse.arguments[0])
            @Expect(recursiveUse.definition, derived)
            @Expect(recursiveUse.arguments.size, 1)
            @Expect(
                recursiveUse.arguments[0]
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                    .id,
                parameter
            )
            @Expect(
                pointerTarget(ctx, fieldType(ctx, base, "usage"))
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                    .id,
                baseParameter
            )
            expectUsedParameters(ctx, base, [baseParameter])
            let y = fieldType(ctx, derived, "y")
                .intoResolver()
                .throughTypeRefs()
                .resolve(ctx)
                .kind
                .expectType()
                .canonicalType(ctx)
            match (y.kind) {
                case TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt) => ()
                case _ => @Assert(false)
            }
            @Expect(ctx.usesTemplateParameter(derived, parameter), false)
            expectUsedParameters(ctx, derived, Array<TypeId>())
        } finally {
            ctx.close()
        }
    }
}
