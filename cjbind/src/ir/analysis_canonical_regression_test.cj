package cjbind.ir

import std.collection.ArrayList
import std.unittest.*
import std.unittest.testmacro.*

func canonicalRegressionFunction(
    ctx: CjbindContext,
    name: String,
    result: TypeId,
    argument: TypeId,
    count: Int64,
    abi: ClangAbi
): TypeId {
    let arguments = ArrayList<(?String, TypeId)>()
    for (_ in 0..count) {
        arguments.add((None, argument))
    }
    return addAnalysisTestType(
        ctx,
        name,
        TypeKind.TypeKindFunction(FunctionSig(
            name,
            result,
            arguments.toArray(),
            false,
            abi
        ))
    )
}

func canonicalRegressionAliasInstance(
    ctx: CjbindContext,
    name: String,
    inner: TypeId,
    parameter: TypeId,
    argument: TypeId
): (TypeId, TypeId) {
    let definition = addAnalysisTestType(
        ctx,
        "${name}Definition",
        TypeKind.TypeKindTemplateAlias(inner, [parameter])
    )
    let instance = analysisInstantiation(ctx, name, definition, [argument])
    return (definition, instance)
}

@Test
public class CanonicalTemplateInstantiationRegressionTest {
    @TestCase
    func rejectsCanonicalAliasCycles(): Unit {
        let ctx = analysisTestContext()
        try {
            let left = addAnalysisTestType(ctx, "Left", TypeKind.TypeKindOpaque)
            let right = addAnalysisTestType(ctx, "Right", TypeKind.TypeKindOpaque)
            ctx.resolveType(left).kind = TypeKind.TypeKindAlias(right)
            ctx.resolveType(right).kind = TypeKind.TypeKindAlias(left)

            @Expect(ctx.resolveType(left).safeCanonicalType(ctx).isNone(), true)
            @Expect(ctx.resolveType(right).safeCanonicalType(ctx).isNone(), true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func detectsTypeParametersHiddenBehindTemplateAliasInstancesInArrays(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let (definition, instance) = canonicalRegressionAliasInstance(
                ctx,
                "IdentityT",
                parameter,
                parameter,
                parameter
            )
            let array = addAnalysisTestType(ctx, "Values", TypeKind.TypeKindArray(instance, 4))
            let results = analyzeHasTypeParameterInArray(
                ctx,
                analysisTestItems([parameter, definition, instance, array])
            )

            @Expect(results.contains(array), true)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func appliesFunctionPointerArgumentLimitThroughTemplateAliasInstances(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let integer = addAnalysisTestType(
                ctx,
                "Integer",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let function = canonicalRegressionFunction(
                ctx,
                "LargeCallback",
                integer,
                integer,
                13,
                ClangAbi.Known(Abi.C)
            )
            let (definition, instance) = canonicalRegressionAliasInstance(
                ctx,
                "LargeCallbackT",
                function,
                parameter,
                integer
            )
            let pointer = addAnalysisTestType(
                ctx,
                "LargeCallbackPointer",
                TypeKind.TypeKindPointer(instance)
            )
            let ids = [parameter, integer, function, definition, instance, pointer]

            @Expect(deriveTestResult(ctx, ids, pointer, DeriveTrait.Debug), CanDerive.Manually)
        } finally {
            ctx.close()
        }
    }

    @TestCase
    func appliesFunctionPointerCallingConventionRuleThroughTemplateAliasInstances(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let integer = addAnalysisTestType(
                ctx,
                "Integer",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let function = canonicalRegressionFunction(
                ctx,
                "StdcallCallback",
                integer,
                integer,
                1,
                ClangAbi.Known(Abi.Stdcall)
            )
            let (definition, instance) = canonicalRegressionAliasInstance(
                ctx,
                "StdcallCallbackT",
                function,
                parameter,
                integer
            )
            let pointer = addAnalysisTestType(
                ctx,
                "StdcallCallbackPointer",
                TypeKind.TypeKindPointer(instance)
            )
            let ids = [parameter, integer, function, definition, instance, pointer]

            @Expect(deriveTestResult(ctx, ids, pointer, DeriveTrait.Debug), CanDerive.Manually)
        } finally {
            ctx.close()
        }
    }
}
