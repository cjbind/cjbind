package cjbind.codegen

import cjbind.ir.*
import cjbind.options.CjbindOptions
import std.collection.HashMap
import std.unittest.*
import std.unittest.testmacro.*

func genericAliasTestContext(): CjbindContext {
    let options = CjbindOptions()
    options.clangArgs.add(all: [
        "-x", "c++", "-std=c++14", "cjbind/src/ir/analysis_test_input.hpp"
    ])
    return CjbindContext(options)
}

func addGenericAliasTestType(
    ctx: CjbindContext,
    name: String,
    kind: TypeKind
): TypeId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(id, None, ctx.rootModule, ItemKind.KindType(Type(Some(name), None, kind, false)), None),
        None,
        None
    )
    return id
}

func markGenericAliasUsage(
    usage: HashMap<ItemId, ItemSet>,
    item: ItemId,
    parameters: Array<TypeId>
): Unit {
    usage.add(item, ItemSet(parameters))
}

@Test
public class GenericAliasRenderingTest {
    @TestCase
    func recursivelyRendersAliasesPointersArraysAndFunctions(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let returnParameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let skippedParameter = addGenericAliasTestType(ctx, "U", TypeKind.TypeKindTypeParam)
            let argumentParameter = addGenericAliasTestType(ctx, "V", TypeKind.TypeKindTypeParam)
            let pointer = addGenericAliasTestType(
                ctx,
                "Pointer",
                TypeKind.TypeKindPointer(returnParameter)
            )
            let array = addGenericAliasTestType(
                ctx,
                "Array",
                TypeKind.TypeKindArray(pointer, 4)
            )
            let alias = addGenericAliasTestType(ctx, "Alias", TypeKind.TypeKindAlias(array))
            let function = addGenericAliasTestType(
                ctx,
                "Function",
                TypeKind.TypeKindFunction(FunctionSig(
                    "callback",
                    returnParameter,
                    [(None, argumentParameter)],
                    false,
                    ClangAbi.Known(Abi.C)
                ))
            )
            let functionPointer = addGenericAliasTestType(
                ctx,
                "FunctionPointer",
                TypeKind.TypeKindPointer(function)
            )

            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, returnParameter, [returnParameter])
            markGenericAliasUsage(usage, skippedParameter, [skippedParameter])
            markGenericAliasUsage(usage, argumentParameter, [argumentParameter])
            markGenericAliasUsage(usage, pointer, [returnParameter])
            markGenericAliasUsage(usage, array, [returnParameter])
            markGenericAliasUsage(usage, alias, [returnParameter])
            markGenericAliasUsage(usage, function, [returnParameter, argumentParameter])
            markGenericAliasUsage(usage, functionPointer, [returnParameter, argumentParameter])
            ctx.usedTemplateParameters = Some(usage)

            let substitutions = HashMap<ItemId, String>()
            substitutions.add(returnParameter, "T")
            substitutions.add(argumentParameter, "V")

            let renderedAlias = renderGenericAliasType(ctx, alias, substitutions, ItemSet())
            let renderedFunction = renderGenericAliasType(ctx, functionPointer, substitutions, ItemSet())
            match (renderedAlias) {
                case Ok(tokens) => @Expect(tokens.toString(), "VArray<CPointer<T>, $4>")
                case Err(_) => @Assert(false)
            }
            match (renderedFunction) {
                case Ok(tokens) => @Expect(tokens.toString(), "CFunc<(arg1: V) -> T>")
                case Err(_) => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func rejectsDependentRecordsInsteadOfInventingGenericCLayouts(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let parameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let comp = CompInfo(CompKind.CompKindStruct, isCxxRecord: true)
            comp.templateParams.add(parameter)
            let record = addGenericAliasTestType(ctx, "Record", TypeKind.TypeKindComp(comp))
            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, parameter, [parameter])
            markGenericAliasUsage(usage, record, [parameter])
            ctx.usedTemplateParameters = Some(usage)
            let substitutions = HashMap<ItemId, String>()
            substitutions.add(parameter, "T")

            match (renderGenericAliasType(ctx, record, substitutions, ItemSet())) {
                case Ok(_) => @Assert(false)
                case Err(error) => @Expect(
                    genericAliasErrorReason(error),
                    "a generic C++ record cannot be represented as an @C type by the current Cangjie FFI"
                )
            }
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func substitutesNestedTemplateAliasInstancesBeforeRendering(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let innerParameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let outerParameter = addGenericAliasTestType(ctx, "U", TypeKind.TypeKindTypeParam)
            let function = addGenericAliasTestType(
                ctx,
                "CallbackFunction",
                TypeKind.TypeKindFunction(FunctionSig(
                    "callback",
                    innerParameter,
                    [(None, innerParameter)],
                    false,
                    ClangAbi.Known(Abi.C)
                ))
            )
            let pointer = addGenericAliasTestType(
                ctx,
                "CallbackPointer",
                TypeKind.TypeKindPointer(function)
            )
            let definition = addGenericAliasTestType(
                ctx,
                "Callback",
                TypeKind.TypeKindTemplateAlias(pointer, [innerParameter])
            )
            let instance = addGenericAliasTestType(
                ctx,
                "CallbackU",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    definition,
                    [outerParameter],
                    ctx.translationUnit.cursor(),
                    None
                ))
            )
            let outerAlias = addGenericAliasTestType(
                ctx,
                "Wrapped",
                TypeKind.TypeKindTemplateAlias(instance, [outerParameter])
            )

            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, innerParameter, [innerParameter])
            markGenericAliasUsage(usage, outerParameter, [outerParameter])
            markGenericAliasUsage(usage, function, [innerParameter])
            markGenericAliasUsage(usage, pointer, [innerParameter])
            markGenericAliasUsage(usage, definition, [innerParameter])
            markGenericAliasUsage(usage, instance, [outerParameter])
            markGenericAliasUsage(usage, outerAlias, [outerParameter])
            ctx.usedTemplateParameters = Some(usage)

            let substitutions = HashMap<ItemId, String>()
            substitutions.add(outerParameter, "U")
            match (renderGenericAliasType(ctx, outerAlias, substitutions, ItemSet())) {
                case Ok(tokens) => @Expect(tokens.toString(), "CFunc<(arg1: U) -> U>")
                case Err(_) => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }
}
