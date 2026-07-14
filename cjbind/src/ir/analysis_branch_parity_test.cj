package cjbind.ir

import std.collection.ArrayList
import std.unittest.*
import std.unittest.testmacro.*

func analysisFunctionType(
    ctx: CjbindContext,
    name: String,
    result: TypeId,
    arguments: Array<TypeId>
): TypeId {
    let parameters = ArrayList<(?String, TypeId)>()
    for (argument in arguments) {
        parameters.add((None, argument))
    }
    return addAnalysisTestType(
        ctx,
        name,
        TypeKind.TypeKindFunction(FunctionSig(
            name,
            result,
            parameters.toArray(),
            false,
            ClangAbi.Known(Abi.C)
        ))
    )
}

func analysisInstantiation(
    ctx: CjbindContext,
    name: String,
    definition: TypeId,
    arguments: Array<TypeId>
): TypeId {
    return addAnalysisTestType(
        ctx,
        name,
        TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
            definition,
            arguments
        ))
    )
}

@Test
public class VtableAnalysisBranchParityTest {
    @TestCase
    func forwardsReferenceKindsAndIgnoresTemplateArgumentsAndFields(): Unit {
        let ctx = analysisTestContext()
        try {
            let virtualComp = analysisTestRecord(Array<TypeId>())
            virtualComp.hasOwnVirtualMethod = true
            let virtualType = addAnalysisTestType(
                ctx,
                "VirtualType",
                TypeKind.TypeKindComp(virtualComp)
            )
            let alias = addAnalysisTestType(ctx, "Alias", TypeKind.TypeKindAlias(virtualType))
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(alias, Array<TypeId>())
            )
            let resolved = addAnalysisTestType(ctx, "Resolved", TypeKind.ResolvedTypeRef(templateAlias))
            let reference = addAnalysisTestType(ctx, "Reference", TypeKind.TypeKindReference(resolved))
            let holder = addAnalysisTestType(
                ctx,
                "Holder",
                TypeKind.TypeKindComp(analysisTestRecord([virtualType]))
            )
            let emptyDefinition = addAnalysisTestType(
                ctx,
                "EmptyDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let argumentOnly = analysisInstantiation(
                ctx,
                "ArgumentOnly",
                emptyDefinition,
                [virtualType]
            )
            let definitionOnly = analysisInstantiation(
                ctx,
                "DefinitionOnly",
                virtualType,
                [emptyDefinition]
            )
            let combinedComp = analysisTestRecord(Array<TypeId>())
            combinedComp.hasOwnVirtualMethod = true
            combinedComp.baseMembers.add(Base(virtualType, BaseKind.Normal, "base", true))
            let combined = addAnalysisTestType(
                ctx,
                "Combined",
                TypeKind.TypeKindComp(combinedComp)
            )
            let ids = [
                virtualType,
                alias,
                templateAlias,
                resolved,
                reference,
                holder,
                emptyDefinition,
                argumentOnly,
                definitionOnly,
                combined
            ]
            let results = computeHasVtable(ctx, analysisTestItems(ids))

            @Expect(hasVtableResultFor(results, alias), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, templateAlias), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, resolved), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, reference), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, holder), HasVtableResult.No)
            @Expect(hasVtableResultFor(results, argumentOnly), HasVtableResult.No)
            @Expect(hasVtableResultFor(results, definitionOnly), HasVtableResult.SelfHasVtable)
            @Expect(hasVtableResultFor(results, combined), HasVtableResult.BaseHasVtable)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class SizednessAnalysisBranchParityTest {
    @TestCase
    func handlesReferenceChainsOpaqueLayoutsAndTemplateDefinitions(): Unit {
        let ctx = analysisTestContext()
        try {
            let empty = addAnalysisTestType(
                ctx,
                "Empty",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let integer = addDeriveTestTypeWithLayout(
                ctx,
                "Integer",
                Layout(4, 4),
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let alias = addAnalysisTestType(ctx, "Alias", TypeKind.TypeKindAlias(integer))
            let opaqueAlias = addAnalysisTestType(
                ctx,
                "OpaqueAlias",
                TypeKind.TypeKindAlias(integer)
            )
            let opaqueArray = addAnalysisTestType(
                ctx,
                "OpaqueArray",
                TypeKind.TypeKindArray(integer, 2)
            )
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(alias, Array<TypeId>())
            )
            let blockPointer = addAnalysisTestType(
                ctx,
                "BlockPointer",
                TypeKind.TypeKindObjCBlockPointer(templateAlias)
            )
            let resolved = addAnalysisTestType(ctx, "Resolved", TypeKind.ResolvedTypeRef(blockPointer))
            let opaqueZero = addDeriveTestTypeWithLayout(
                ctx,
                "OpaqueZero",
                Layout(0, 1),
                TypeKind.TypeKindOpaque
            )
            let opaqueNonZero = addDeriveTestTypeWithLayout(
                ctx,
                "OpaqueNonZero",
                Layout(24, 8),
                TypeKind.TypeKindOpaque
            )
            let ordinaryInstance = addDeriveTestTypeWithLayout(
                ctx,
                "OrdinaryInstance",
                Layout(16, 8),
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    empty,
                    [integer]
                ))
            )
            let opaqueInstance = addDeriveTestTypeWithLayout(
                ctx,
                "OpaqueInstance",
                Layout(16, 8),
                TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                    opaqueZero,
                    [integer]
                ))
            )
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let joinedComp = analysisTestRecord(Array<TypeId>())
            joinedComp.baseMembers.add(Base(parameter, BaseKind.Normal, "dependent", true))
            joinedComp.baseMembers.add(Base(integer, BaseKind.Normal, "concrete", true))
            let joined = addAnalysisTestType(ctx, "Joined", TypeKind.TypeKindComp(joinedComp))
            let ids = [
                empty,
                integer,
                alias,
                opaqueAlias,
                opaqueArray,
                templateAlias,
                blockPointer,
                resolved,
                opaqueZero,
                opaqueNonZero,
                ordinaryInstance,
                opaqueInstance,
                parameter,
                joined
            ]
            ctx.options.opaqueTypes.add(#"^OpaqueAlias$"#)
            ctx.options.opaqueTypes.add(#"^array2_Integer$"#)
            @Expect(ctx.isOpaqueByName(ctx.resolveItem(opaqueAlias)), true)
            @Expect(ctx.isOpaqueByName(ctx.resolveItem(opaqueArray)), true)
            @Expect(analysisLayout(ctx.resolveType(opaqueAlias), ctx).isNone(), true)
            @Expect(analysisLayout(ctx.resolveType(opaqueArray), ctx).isNone(), true)
            let items = analysisTestItems(ids)
            let results = computeSizedness(ctx, items, computeHasVtable(ctx, items))

            @Expect(sizednessResultFor(results, alias), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, opaqueAlias), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, opaqueArray), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, templateAlias), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, blockPointer), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, resolved), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, opaqueZero), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, opaqueNonZero), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, ordinaryInstance), SizednessResult.ZeroSized)
            @Expect(sizednessResultFor(results, opaqueInstance), SizednessResult.NonZeroSized)
            @Expect(sizednessResultFor(results, joined), SizednessResult.NonZeroSized)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class DestructorAnalysisBranchParityTest {
    @TestCase
    func propagatesThroughEveryOwningEdgeButNotPointersOrUnionFields(): Unit {
        let ctx = analysisTestContext()
        try {
            let ownComp = analysisTestRecord(Array<TypeId>())
            ownComp.hasDestructor = true
            let own = addAnalysisTestType(ctx, "Own", TypeKind.TypeKindComp(ownComp))
            let alias = addAnalysisTestType(ctx, "Alias", TypeKind.TypeKindAlias(own))
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(alias, Array<TypeId>())
            )
            let resolved = addAnalysisTestType(ctx, "Resolved", TypeKind.ResolvedTypeRef(templateAlias))
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(own))
            let function = analysisFunctionType(ctx, "Function", own, [own])
            let baseComp = analysisTestRecord(Array<TypeId>())
            baseComp.baseMembers.add(Base(resolved, BaseKind.Normal, "base", true))
            let baseHolder = addAnalysisTestType(ctx, "BaseHolder", TypeKind.TypeKindComp(baseComp))
            let fieldHolder = addAnalysisTestType(
                ctx,
                "FieldHolder",
                TypeKind.TypeKindComp(analysisTestRecord([resolved]))
            )
            let unionHolder = addAnalysisTestType(
                ctx,
                "UnionHolder",
                TypeKind.TypeKindComp(deriveTestUnion([own]))
            )
            let cleanDefinition = addAnalysisTestType(
                ctx,
                "CleanDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let definitionInstance = analysisInstantiation(
                ctx,
                "DefinitionInstance",
                own,
                [cleanDefinition]
            )
            let argumentInstance = analysisInstantiation(
                ctx,
                "ArgumentInstance",
                cleanDefinition,
                [own]
            )
            let ids = [
                own,
                alias,
                templateAlias,
                resolved,
                pointer,
                function,
                baseHolder,
                fieldHolder,
                unionHolder,
                cleanDefinition,
                definitionInstance,
                argumentInstance
            ]
            let results = analyzeHasDestructor(ctx, analysisTestItems(ids))

            @Expect(results.contains(alias), true)
            @Expect(results.contains(templateAlias), true)
            @Expect(results.contains(resolved), true)
            @Expect(results.contains(pointer), false)
            @Expect(results.contains(function), false)
            @Expect(results.contains(baseHolder), true)
            @Expect(results.contains(fieldHolder), true)
            @Expect(results.contains(unionHolder), false)
            @Expect(results.contains(definitionInstance), true)
            @Expect(results.contains(argumentInstance), true)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class TypeParameterArrayAnalysisBranchParityTest {
    @TestCase
    func propagatesThroughReferenceKindsAndBothSidesOfInstantiation(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let parameterAlias = addAnalysisTestType(ctx, "ParameterAlias", TypeKind.TypeKindAlias(parameter))
            let array = addAnalysisTestType(ctx, "Array", TypeKind.TypeKindArray(parameterAlias, 2))
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(array, Array<TypeId>())
            )
            let resolved = addAnalysisTestType(ctx, "Resolved", TypeKind.ResolvedTypeRef(templateAlias))
            let blockPointer = addAnalysisTestType(
                ctx,
                "BlockPointer",
                TypeKind.TypeKindObjCBlockPointer(resolved)
            )
            let pointerToParameter = addAnalysisTestType(
                ctx,
                "PointerToParameter",
                TypeKind.TypeKindPointer(parameter)
            )
            let pointerArray = addAnalysisTestType(
                ctx,
                "PointerArray",
                TypeKind.TypeKindArray(pointerToParameter, 2)
            )
            let function = analysisFunctionType(ctx, "Function", array, [array])
            let definition = addAnalysisTestType(
                ctx,
                "Definition",
                TypeKind.TypeKindComp(analysisTestRecord([array]))
            )
            let cleanDefinition = addAnalysisTestType(
                ctx,
                "CleanDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let definitionInstance = analysisInstantiation(
                ctx,
                "DefinitionInstance",
                definition,
                [pointerToParameter]
            )
            let argumentInstance = analysisInstantiation(
                ctx,
                "ArgumentInstance",
                cleanDefinition,
                [array]
            )
            let ids = [
                parameter,
                parameterAlias,
                array,
                templateAlias,
                resolved,
                blockPointer,
                pointerToParameter,
                pointerArray,
                function,
                definition,
                cleanDefinition,
                definitionInstance,
                argumentInstance
            ]
            let results = analyzeHasTypeParameterInArray(ctx, analysisTestItems(ids))

            @Expect(results.contains(array), true)
            @Expect(results.contains(templateAlias), true)
            @Expect(results.contains(resolved), true)
            @Expect(results.contains(blockPointer), true)
            @Expect(results.contains(pointerToParameter), false)
            @Expect(results.contains(pointerArray), false)
            @Expect(results.contains(function), false)
            @Expect(results.contains(definitionInstance), true)
            @Expect(results.contains(argumentInstance), true)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class FloatAnalysisBranchParityTest {
    @TestCase
    func propagatesComplexAndBitfieldValuesAcrossAliasesAndInstantiations(): Unit {
        let ctx = analysisTestContext()
        try {
            let floating = addDeriveTestTypeWithLayout(
                ctx,
                "Floating",
                Layout(4, 4),
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindFloat)
            )
            let complex = addAnalysisTestType(
                ctx,
                "Complex",
                TypeKind.TypeKindComplex(TypeKindFloatKind.FloatKindDouble)
            )
            let alias = addAnalysisTestType(ctx, "Alias", TypeKind.TypeKindAlias(complex))
            let templateAlias = addAnalysisTestType(
                ctx,
                "TemplateAlias",
                TypeKind.TypeKindTemplateAlias(alias, Array<TypeId>())
            )
            let resolved = addAnalysisTestType(ctx, "Resolved", TypeKind.ResolvedTypeRef(templateAlias))
            let blockPointer = addAnalysisTestType(
                ctx,
                "BlockPointer",
                TypeKind.TypeKindObjCBlockPointer(resolved)
            )
            let pointer = addAnalysisTestType(ctx, "Pointer", TypeKind.TypeKindPointer(floating))
            let function = analysisFunctionType(ctx, "Function", floating, [floating])
            let bitfieldData = RawField(Some("value"), floating, None, Some(1), Some(0))
            let bitfieldComp = analysisTestRecord(Array<TypeId>())
            bitfieldComp.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(
                [Field.Bitfields(BitfieldUnit(0, Layout(1, 1), [Bitfield(0, bitfieldData)]))],
                true
            ))
            let bitfieldHolder = addAnalysisTestType(
                ctx,
                "BitfieldHolder",
                TypeKind.TypeKindComp(bitfieldComp)
            )
            let definition = addAnalysisTestType(
                ctx,
                "Definition",
                TypeKind.TypeKindComp(analysisTestRecord([floating]))
            )
            let cleanDefinition = addAnalysisTestType(
                ctx,
                "CleanDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let definitionInstance = analysisInstantiation(
                ctx,
                "DefinitionInstance",
                definition,
                [pointer]
            )
            let argumentInstance = analysisInstantiation(
                ctx,
                "ArgumentInstance",
                cleanDefinition,
                [floating]
            )
            let ids = [
                floating,
                complex,
                alias,
                templateAlias,
                resolved,
                blockPointer,
                pointer,
                function,
                bitfieldHolder,
                definition,
                cleanDefinition,
                definitionInstance,
                argumentInstance
            ]
            let results = analyzeHasFloat(ctx, analysisTestItems(ids))

            @Expect(results.contains(complex), true)
            @Expect(results.contains(alias), true)
            @Expect(results.contains(templateAlias), true)
            @Expect(results.contains(resolved), true)
            @Expect(results.contains(blockPointer), true)
            @Expect(results.contains(pointer), false)
            @Expect(results.contains(function), false)
            @Expect(results.contains(bitfieldHolder), true)
            @Expect(results.contains(definitionInstance), true)
            @Expect(results.contains(argumentInstance), true)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class UsedTemplateParameterEdgeParityTest {
    @TestCase
    func ignoresMethodsAndNestedItemsButIncludesFunctionsConstructorsAndDestructors(): Unit {
        let ctx = analysisTestContext()
        try {
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let signature = analysisFunctionType(ctx, "Signature", parameter, [parameter])

            let methodComp = analysisTestRecord(Array<TypeId>())
            methodComp.templateParams.add(parameter)
            methodComp.methods.add(Method(MethodKind.Normal, signature, false))
            let methodOnly = addAnalysisTestType(
                ctx,
                "MethodOnly",
                TypeKind.TypeKindComp(methodComp)
            )

            let constructorComp = analysisTestRecord(Array<TypeId>())
            constructorComp.templateParams.add(parameter)
            constructorComp.constructors.add(signature)
            let constructorUse = addAnalysisTestType(
                ctx,
                "ConstructorUse",
                TypeKind.TypeKindComp(constructorComp)
            )

            let destructorComp = analysisTestRecord(Array<TypeId>())
            destructorComp.templateParams.add(parameter)
            destructorComp.destructor = Some((MethodKind.Destructor, signature))
            let destructorUse = addAnalysisTestType(
                ctx,
                "DestructorUse",
                TypeKind.TypeKindComp(destructorComp)
            )

            let nestedComp = analysisTestRecord([parameter])
            let nested = addAnalysisTestType(ctx, "Nested", TypeKind.TypeKindComp(nestedComp))
            let nestedOwnerComp = analysisTestRecord(Array<TypeId>())
            nestedOwnerComp.templateParams.add(parameter)
            nestedOwnerComp.innerTypes.add(nested)
            let nestedOwner = addAnalysisTestType(
                ctx,
                "NestedOwner",
                TypeKind.TypeKindComp(nestedOwnerComp)
            )

            let ids = [parameter, signature, methodOnly, constructorUse, destructorUse, nested, nestedOwner]
            let results = analyzeUsedTemplateParameters(ctx, analysisTestItems(ids))

            @Expect(results.get(signature).getOrThrow().contains(parameter), true)
            @Expect(results.get(methodOnly).getOrThrow().contains(parameter), false)
            @Expect(results.get(constructorUse).getOrThrow().contains(parameter), true)
            @Expect(results.get(destructorUse).getOrThrow().contains(parameter), true)
            @Expect(results.get(nested).getOrThrow().contains(parameter), true)
            @Expect(results.get(nestedOwner).getOrThrow().contains(parameter), false)
        } finally {
            ctx.close()
        }
    }
}

@Test
public class TemplateArgumentIdentityTest {
    @TestCase
    func comparesExactTypeIdsWithoutAliasCanonicalization(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(
                ctx,
                "Integer",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let firstAlias = addAnalysisTestType(
                ctx,
                "FirstAlias",
                TypeKind.TypeKindAlias(integer)
            )
            let secondAlias = addAnalysisTestType(
                ctx,
                "SecondAlias",
                TypeKind.TypeKindAlias(integer)
            )

            @Expect(ctx.sameTemplateArguments([firstAlias], [firstAlias]), true)
            @Expect(ctx.sameTemplateArguments([firstAlias], [secondAlias]), false)
            @Expect(ctx.sameTemplateArguments([firstAlias], [integer]), false)
        } finally {
            ctx.close()
        }
    }
}
