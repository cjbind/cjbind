package cjbind.codegen

import cjbind.ir.*
import cjbind.ir.analysis.AnalysisResults
import cjbind.options.CjbindOptions
import std.collection.HashMap
import std.unittest.*
import std.unittest.testmacro.*

func genericAliasTestContext(): CjbindContext {
    let options = CjbindOptions()
    options.clangArgs.add(all: [
        "-x", "c++", "-std=c++14", "cjbind_test/testdata/headers/support/ir/analysis_test_input.hpp"
    ])
    return CjbindContext(options)
}

func addGenericAliasTestType(
    ctx: CjbindContext,
    name: String,
    kind: TypeKind,
    parentId!: ?ItemId = None
): TypeId {
    let id = ctx.nextItemId()
    ctx.addItem(
        Item(
            id,
            None,
            parentId.getOrDefault({=> ctx.rootModule}),
            ItemKind.KindType(Type(Some(name), None, kind, false)),
            None
        ),
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
    func preservesAliasPaths(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let returnParameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let skippedParameter = addGenericAliasTestType(ctx, "U", TypeKind.TypeKindTypeParam)
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
            let ownerInfo = CompInfo(CompKind.CompKindStruct, isCxxRecord: true)
            ownerInfo.templateParams.add(returnParameter)
            let owner = addGenericAliasTestType(
                ctx,
                "Owner",
                TypeKind.TypeKindComp(ownerInfo)
            )
            let alias = addGenericAliasTestType(
                ctx,
                "Alias",
                TypeKind.TypeKindAlias(array),
                parentId: owner
            )

            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, returnParameter, [returnParameter])
            markGenericAliasUsage(usage, skippedParameter, [skippedParameter])
            markGenericAliasUsage(usage, pointer, [returnParameter])
            markGenericAliasUsage(usage, array, [returnParameter])
            markGenericAliasUsage(usage, owner, [returnParameter])
            markGenericAliasUsage(usage, alias, [returnParameter])
            ctx.installAnalysisResults(AnalysisResults(usage))

            let substitutions = HashMap<ItemId, String>()
            substitutions.add(returnParameter, "T")

            let renderedAlias = renderGenericAliasType(ctx, alias, substitutions, ItemSet())
            match (renderedAlias) {
                case Ok(tokens) => @Expect(tokens.toString(), "Owner_Alias<T>")
                case Err(_) => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func preservesGenericFunctionPointerAsOpaquePointerWhenItsValueAbiCannotBeNamed(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let returnParameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let argumentParameter = addGenericAliasTestType(ctx, "V", TypeKind.TypeKindTypeParam)
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
            markGenericAliasUsage(usage, argumentParameter, [argumentParameter])
            markGenericAliasUsage(usage, function, [returnParameter, argumentParameter])
            markGenericAliasUsage(usage, functionPointer, [returnParameter, argumentParameter])
            ctx.installAnalysisResults(AnalysisResults(usage))
            let substitutions = HashMap<ItemId, String>()
            substitutions.add(returnParameter, "T")
            substitutions.add(argumentParameter, "V")

            let visiting = ItemSet()
            match (renderGenericAliasType(ctx, functionPointer, substitutions, visiting)) {
                case Ok(tokens) => @Expect(tokens.toString(), "CPointer<Unit>")
                case Err(_) => @Assert(false)
            }
            @Expect(visiting.isEmpty(), true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func preservesGenericPointerWithoutCTypeConstraint(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let parameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let pointer = addGenericAliasTestType(
                ctx,
                "Pointer",
                TypeKind.TypeKindPointer(parameter)
            )
            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, parameter, [parameter])
            markGenericAliasUsage(usage, pointer, [parameter])
            ctx.installAnalysisResults(AnalysisResults(usage))
            let substitutions = HashMap<ItemId, String>()
            substitutions.add(parameter, "T")

            match (renderGenericAliasType(ctx, pointer, substitutions, ItemSet())) {
                case Ok(tokens) => @Expect(tokens.toString(), "CPointer<T>")
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
            ctx.installAnalysisResults(AnalysisResults(usage))
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
    func erasesAliasesWhoseGenericRecordTargetsAreIndirect(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let parameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let comp = CompInfo(CompKind.CompKindStruct, isCxxRecord: true)
            comp.templateParams.add(parameter)
            let record = addGenericAliasTestType(ctx, "FixedArray", TypeKind.TypeKindComp(comp))
            let pointer = addGenericAliasTestType(
                ctx,
                "FixedArrayPointer",
                TypeKind.TypeKindPointer(record)
            )
            let alias = addGenericAliasTestType(
                ctx,
                "Fixed16",
                TypeKind.TypeKindTemplateAlias(pointer, [parameter])
            )
            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, parameter, [parameter])
            markGenericAliasUsage(usage, record, [parameter])
            markGenericAliasUsage(usage, pointer, [parameter])
            markGenericAliasUsage(usage, alias, [parameter])
            ctx.installAnalysisResults(AnalysisResults(usage))

            let result = CodegenResult()
            let aliasItem = ctx.resolveItem(alias)
            codegenTypeAlias(
                aliasItem.kind.expectType(),
                pointer,
                ctx,
                result,
                aliasItem
            )

            @Expect(result.items.size, 1)
            @Expect(result.items[0].toString(), "public type Fixed16<T> = CPointer<Unit>")
            @Expect(result.seenType(aliasItem.canonicalName(ctx)), true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func preservesNestedTemplateAliasInstancesWithOpaqueFunctionPointers(): Unit {
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
                    [outerParameter]
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
            ctx.installAnalysisResults(AnalysisResults(usage))

            let substitutions = HashMap<ItemId, String>()
            substitutions.add(outerParameter, "U")
            match (renderGenericAliasType(ctx, instance, substitutions, ItemSet())) {
                case Ok(tokens) => @Expect(tokens.toString(), "Callback<U>")
                case Err(_) => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func rendersConcreteInstanceOfUnsupportedGenericFunctionAlias(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let parameter = addGenericAliasTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let integer = addGenericAliasTestType(
                ctx,
                "Integer",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let function = addGenericAliasTestType(
                ctx,
                "Function",
                TypeKind.TypeKindFunction(FunctionSig(
                    "callback",
                    parameter,
                    [(None, parameter)],
                    false,
                    ClangAbi.Known(Abi.C)
                ))
            )
            let pointer = addGenericAliasTestType(
                ctx,
                "FunctionPointer",
                TypeKind.TypeKindPointer(function)
            )
            let definition = addGenericAliasTestType(
                ctx,
                "Callback",
                TypeKind.TypeKindTemplateAlias(pointer, [parameter])
            )
            let instance = addGenericAliasTestType(
                ctx,
                "IntCallback",
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    definition,
                    [integer]
                ))
            )
            let usage = HashMap<ItemId, ItemSet>()
            markGenericAliasUsage(usage, parameter, [parameter])
            markGenericAliasUsage(usage, integer, Array<TypeId>())
            markGenericAliasUsage(usage, function, [parameter])
            markGenericAliasUsage(usage, pointer, [parameter])
            markGenericAliasUsage(usage, definition, [parameter])
            markGenericAliasUsage(usage, instance, Array<TypeId>())
            ctx.installAnalysisResults(AnalysisResults(usage))

            match (instance.tryToCjTy(ctx, ())) {
                case Ok(tokens) => @Expect(tokens.toString(), "CFunc<(arg1: Int32) -> Int32>")
                case Err(_) => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func reportsUnsupportedCallingConventionsAsErrors(): Unit {
        let ctx = genericAliasTestContext()
        try {
            let unit = addGenericAliasTestType(ctx, "Unit", TypeKind.TypeKindVoid)
            let substitutions = HashMap<ItemId, String>()
            let visiting = ItemSet()
            let ctypeSubstitutions = ItemSet()
            let valueAbiSubstitutions = ItemSet()

            let unsupported = renderGenericAliasFunction(
                ctx,
                FunctionSig(
                    "fastCallback",
                    unit,
                    Array<(Option<String>, TypeId)>(),
                    false,
                    ClangAbi.Known(Abi.Fastcall),
                    valueAbiUnsupported: true
                ),
                substitutions,
                visiting,
                ctypeSubstitutions,
                valueAbiSubstitutions,
                Box(false)
            )
            match (unsupported) {
                case Err(error) => @Expect(genericAliasDiagnosticLevel(error), "Error")
                case Ok(_) => @Assert(false)
            }

            let ordinary = renderGenericAliasFunction(
                ctx,
                FunctionSig(
                    "variadicCallback",
                    unit,
                    [(None, unit)],
                    true,
                    ClangAbi.Known(Abi.C)
                ),
                substitutions,
                visiting,
                ctypeSubstitutions,
                valueAbiSubstitutions,
                Box(false)
            )
            match (ordinary) {
                case Err(error) => @Expect(genericAliasDiagnosticLevel(error), "Warning")
                case Ok(_) => @Assert(false)
            }
        } finally {
            ctx.close()
        }
    }
}
