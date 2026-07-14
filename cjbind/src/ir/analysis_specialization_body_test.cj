package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class MaterializedTemplateSpecializationAnalysisTest {
    @TestCase
    func explicitAndPartialSpecializationsUseTheirMaterializedBodies(): Unit {
        let ctx = analysisTestContext()
        try {
            let integer = addAnalysisTestType(
                ctx,
                "Integer",
                TypeKind.TypeKindInt(TypeKindIntKind.IntKindInt)
            )
            let floating = addAnalysisTestType(
                ctx,
                "Floating",
                TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindDouble)
            )
            let parameter = addAnalysisTestType(ctx, "T", TypeKind.TypeKindTypeParam)
            let parameterArray = addAnalysisTestType(
                ctx,
                "ParameterArray",
                TypeKind.TypeKindArray(parameter, 4)
            )

            let emptyDefinition = addAnalysisTestType(
                ctx,
                "EmptyDefinition",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            let factfulDefinitionComp = analysisTestRecord([floating, parameterArray])
            factfulDefinitionComp.hasOwnVirtualMethod = true
            factfulDefinitionComp.hasDestructor = true
            let factfulDefinition = addAnalysisTestType(
                ctx,
                "FactfulDefinition",
                TypeKind.TypeKindComp(factfulDefinitionComp)
            )

            let explicitComp = analysisTestRecord([floating, parameterArray])
            explicitComp.hasOwnVirtualMethod = true
            explicitComp.hasDestructor = true
            let explicitSpecialization = addAnalysisTestType(
                ctx,
                "ExplicitSpecialization",
                TypeKind.TypeKindComp(explicitComp)
            )
            ctx.concreteTemplateInstantiations.add(
                explicitSpecialization,
                TemplateInstantiation(
                    emptyDefinition,
                    [integer],
                    ctx.translationUnit.cursor(),
                    None,
                    kind: TemplateInstantiationKind.ExplicitSpecialization
                )
            )

            let partialSpecialization = addAnalysisTestType(
                ctx,
                "PartialSpecialization",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            ctx.concreteTemplateInstantiations.add(
                partialSpecialization,
                TemplateInstantiation(
                    factfulDefinition,
                    [integer],
                    ctx.translationUnit.cursor(),
                    None,
                    kind: TemplateInstantiationKind.PartialSpecialization
                )
            )

            let argumentDependentSpecialization = addAnalysisTestType(
                ctx,
                "ArgumentDependentSpecialization",
                TypeKind.TypeKindComp(analysisTestRecord(Array<TypeId>()))
            )
            ctx.concreteTemplateInstantiations.add(
                argumentDependentSpecialization,
                TemplateInstantiation(
                    emptyDefinition,
                    [parameter],
                    ctx.translationUnit.cursor(),
                    None,
                    kind: TemplateInstantiationKind.PartialSpecialization
                )
            )

            let items = analysisTestItems([
                integer,
                floating,
                parameter,
                parameterArray,
                emptyDefinition,
                factfulDefinition,
                explicitSpecialization,
                partialSpecialization,
                argumentDependentSpecialization
            ])

            let vtables = computeHasVtable(ctx, items)
            @Expect(
                hasVtableResultFor(vtables, explicitSpecialization),
                HasVtableResult.SelfHasVtable
            )
            @Expect(hasVtableResultFor(vtables, partialSpecialization), HasVtableResult.No)
            ctx.haveVtable = Some(vtables)

            let destructors = analyzeHasDestructor(ctx, items)
            @Expect(destructors.contains(explicitSpecialization), true)
            @Expect(destructors.contains(partialSpecialization), false)
            ctx.haveDestructor = Some(destructors)

            let floats = analyzeHasFloat(ctx, items)
            @Expect(floats.contains(explicitSpecialization), true)
            @Expect(floats.contains(partialSpecialization), false)

            let parameterArrays = analyzeHasTypeParameterInArray(ctx, items)
            @Expect(parameterArrays.contains(explicitSpecialization), true)
            @Expect(parameterArrays.contains(partialSpecialization), false)

            let sizedness = computeSizedness(ctx, items, vtables)
            @Expect(sizedness.get(explicitSpecialization).getOrThrow(), SizednessResult.NonZeroSized)
            @Expect(
                sizedness.get(partialSpecialization).getOrDefault({=> SizednessResult.ZeroSized}),
                SizednessResult.ZeroSized
            )

            let copyResults = analyzeCanDerive(ctx, items, DeriveTrait.Copy)
            @Expect(copyResults.get(explicitSpecialization).getOrThrow(), CanDerive.No)
            @Expect(
                copyResults.get(partialSpecialization).getOrDefault({=> CanDerive.Yes}),
                CanDerive.Yes
            )

            let defaultResults = analyzeCanDerive(ctx, items, DeriveTrait.Default)
            @Expect(defaultResults.get(explicitSpecialization).getOrThrow(), CanDerive.No)
            @Expect(
                defaultResults.get(partialSpecialization).getOrDefault({=> CanDerive.Yes}),
                CanDerive.Yes
            )

            let hashResults = analyzeCanDerive(ctx, items, DeriveTrait.Hash)
            @Expect(hashResults.get(explicitSpecialization).getOrThrow(), CanDerive.No)
            @Expect(
                hashResults.get(partialSpecialization).getOrDefault({=> CanDerive.Yes}),
                CanDerive.Yes
            )

            let usedParameters = analyzeUsedTemplateParameters(ctx, items)
            @Expect(
                usedParameters.get(explicitSpecialization).getOrThrow().contains(parameter),
                true
            )
            @Expect(
                usedParameters.get(partialSpecialization).getOrThrow().contains(parameter),
                false
            )
            @Expect(
                usedParameters.get(argumentDependentSpecialization).getOrThrow().contains(parameter),
                true
            )
        } finally {
            ctx.close()
        }
    }
}
