package cjbind.ir

import std.collection.{ArrayList, HashMap}

const DERIVE_ARRAY_LIMIT: UIntNative = 32
const DERIVE_ALIGNMENT_LIMIT: Int32 = 32

public enum CanDerive <: Equatable<CanDerive> {
    Yes
    | Manually
    | No

    public operator func ==(rhs: CanDerive): Bool {
        return match ((this, rhs)) {
            case (Yes, Yes) | (Manually, Manually) | (No, No) => true
            case _ => false
        }
    }

    func rank(): UInt8 {
        return match (this) {
            case Yes => 0
            case Manually => 1
            case No => 2
        }
    }

    public func join(rhs: CanDerive): CanDerive {
        if (this.rank() >= rhs.rank()) {
            return this
        }
        return rhs
    }
}

public enum DeriveTrait <: Equatable<DeriveTrait> & ToString {
    Copy
    | Debug
    | Default
    | Hash
    | PartialEqOrPartialOrd

    public operator func ==(rhs: DeriveTrait): Bool {
        return match ((this, rhs)) {
            case (Copy, Copy) |
                (Debug, Debug) |
                (Default, Default) |
                (Hash, Hash) |
                (PartialEqOrPartialOrd, PartialEqOrPartialOrd) => true
            case _ => false
        }
    }

    public func toString(): String {
        return match (this) {
            case Copy => "Copy"
            case Debug => "Debug"
            case Default => "Default"
            case Hash => "Hash"
            case PartialEqOrPartialOrd => "PartialEq/PartialOrd"
        }
    }
}

func considerDeriveEdge(kind: EdgeKind): Bool {
    return match (kind) {
        case EdgeKind.BaseMemberEdge |
            EdgeKind.FieldEdge |
            EdgeKind.TypeReferenceEdge |
            EdgeKind.VarTypeEdge |
            EdgeKind.TemplateArgumentEdge |
            EdgeKind.TemplateDeclarationEdge |
            EdgeKind.TemplateParameterDefinitionEdge => true
        case _ => false
    }
}

class DeriveJoinTracer <: Tracer {
    let analysis: CannotDeriveAnalysis
    let itemId: ItemId
    let considerEdge: (EdgeKind) -> Bool
    var result: CanDerive = CanDerive.Yes

    init(
        analysis: CannotDeriveAnalysis,
        itemId: ItemId,
        considerEdge: (EdgeKind) -> Bool
    ) {
        this.analysis = analysis
        this.itemId = itemId
        this.considerEdge = considerEdge
    }

    public func visitKind(subItem: ItemId, kind: EdgeKind): Unit {
        if (subItem != this.itemId && this.considerEdge(kind)) {
            this.result = this.result.join(this.analysis.resultFor(subItem))
        }
    }
}

public class CannotDeriveAnalysis <: MonotoneFramework<ItemId, HashMap<ItemId, CanDerive>> {
    let ctx: CjbindContext
    let allowlistedItems: ItemSet
    let analysisItems: ItemSet
    let deriveTrait: DeriveTrait
    let canDerive: HashMap<ItemId, CanDerive> = HashMap()
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>

    public init(ctx: CjbindContext, items: ItemSet, deriveTrait: DeriveTrait) {
        this.ctx = ctx
        this.allowlistedItems = items
        this.analysisItems = reachableAnalysisItems(ctx, items)
        this.deriveTrait = deriveTrait
        this.dependencies = generateAnalysisDependencies(ctx, this.analysisItems, considerDeriveEdge)
    }

    public func initialWorklist(): Array<ItemId> {
        return analysisItemsToArray(this.analysisItems)
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id)
            .map({values => values.toArray()})
            .getOrDefault({=> Array<ItemId>()})
    }

    public func resultFor(id: ItemId): CanDerive {
        return this.canDerive.get(id).getOrDefault({=> CanDerive.Yes})
    }

    public func finish(): HashMap<ItemId, CanDerive> {
        return this.canDerive
    }

    func insert(id: ItemId, result: CanDerive): ConstrainResult {
        if (result == CanDerive.Yes) {
            return ConstrainResult.Same
        }
        let previous = this.resultFor(id)
        let joined = previous.join(result)
        if (joined == previous) {
            return ConstrainResult.Same
        }
        this.canDerive.add(id, joined)
        return ConstrainResult.Changed
    }

    func canDeriveLargeArray(): Bool {
        return this.deriveTrait != DeriveTrait.Default
    }

    func canDeriveUnion(): Bool {
        return this.deriveTrait == DeriveTrait.Copy
    }

    func canDeriveCompoundWithDestructor(): Bool {
        return this.deriveTrait != DeriveTrait.Copy
    }

    func canDeriveCompoundWithVtable(): Bool {
        return this.deriveTrait != DeriveTrait.Default
    }

    func canDeriveCompoundForwardDeclaration(): Bool {
        return this.deriveTrait == DeriveTrait.Debug
    }

    func canDeriveIncompleteArray(): Bool {
        return this.deriveTrait != DeriveTrait.Copy &&
            this.deriveTrait != DeriveTrait.Hash &&
            this.deriveTrait != DeriveTrait.PartialEqOrPartialOrd
    }

    func canDerivePointer(): CanDerive {
        if (this.deriveTrait == DeriveTrait.Default) {
            return CanDerive.No
        }
        return CanDerive.Yes
    }

    func functionPointerSupported(signature: FunctionSig): Bool {
        if (signature.argumentTypes.size > 12) {
            return false
        }
        return match (signature.abi) {
            case ClangAbi.Known(Abi.C) | ClangAbi.Unknown(_) => true
            case _ => false
        }
    }

    func canDeriveFunctionPointer(signature: FunctionSig): CanDerive {
        let supported = this.functionPointerSupported(signature)
        if (this.deriveTrait == DeriveTrait.Copy || this.deriveTrait == DeriveTrait.Default || supported) {
            return CanDerive.Yes
        }
        if (this.deriveTrait == DeriveTrait.Debug) {
            return CanDerive.Manually
        }
        return CanDerive.No
    }

    func canDeriveSimple(kind: TypeKind): CanDerive {
        if (this.deriveTrait == DeriveTrait.Default) {
            match (kind) {
                case TypeKind.TypeKindVoid |
                    TypeKind.TypeKindNullPtr |
                    TypeKind.TypeKindEnum(_) |
                    TypeKind.TypeKindReference(_) |
                    TypeKind.TypeKindTypeParam |
                    TypeKind.TypeKindObjCInterface(_) |
                    TypeKind.TypeKindObjCId |
                    TypeKind.TypeKindObjCSel => return CanDerive.No
                case TypeKind.UnresolvedTypeRef(_, _, _) =>
                    throw Exception("unresolved type reached derive analysis")
                case _ => ()
            }
        }
        if (this.deriveTrait == DeriveTrait.Hash) {
            match (kind) {
                case TypeKind.TypeKindFloat(_) | TypeKind.TypeKindComplex(_) => return CanDerive.No
                case _ => ()
            }
        }
        return CanDerive.Yes
    }

    func constrainJoin(item: Item, considerEdge: (EdgeKind) -> Bool): CanDerive {
        let tracer = DeriveJoinTracer(this, item.id, considerEdge)
        item.trace(this.ctx, tracer, ())
        return tracer.result
    }

    func constrainInstantiation(
        itemId: ItemId,
        instantiation: TemplateInstantiation
    ): CanDerive {
        var result = CanDerive.Yes
        if (instantiation.definition != itemId) {
            result = result.join(this.resultFor(instantiation.definition))
        }
        for (argument in instantiation.arguments) {
            if (argument != itemId) {
                result = result.join(this.resultFor(argument))
            }
        }
        return result
    }

    func constrainArray(inner: TypeId, length: UIntNative): CanDerive {
        if (this.resultFor(inner) != CanDerive.Yes) {
            return CanDerive.No
        }
        if (length == 0 && !this.canDeriveIncompleteArray()) {
            return CanDerive.No
        }
        if (this.canDeriveLargeArray()) {
            return CanDerive.Yes
        }
        if (length > DERIVE_ARRAY_LIMIT) {
            return CanDerive.Manually
        }
        return CanDerive.Yes
    }

    func constrainVector(inner: TypeId, length: UIntNative): CanDerive {
        if (this.resultFor(inner) != CanDerive.Yes) {
            return CanDerive.No
        }
        if (length == 0) {
            throw Exception("vectors cannot have zero length")
        }
        if (this.deriveTrait == DeriveTrait.PartialEqOrPartialOrd) {
            return CanDerive.No
        }
        return CanDerive.Yes
    }

    func hasTooLargeBitfieldUnit(comp: CompInfo): Bool {
        return match (comp.fields) {
            case CompFields.CompFieldsAfter(value) => value.fields.iterator().any {
                field => match (field) {
                    case Field.Bitfields(unit) => unit.layout.size > 32
                    case _ => false
                }
            }
            case _ => false
        }
    }

    func compEdge(kind: EdgeKind): Bool {
        if (this.deriveTrait == DeriveTrait.PartialEqOrPartialOrd) {
            return match (kind) {
                case EdgeKind.TemplateArgumentEdge |
                    EdgeKind.TemplateDeclarationEdge => false
                case _ => considerDeriveEdge(kind)
            }
        }
        return match (kind) {
            case EdgeKind.BaseMemberEdge | EdgeKind.FieldEdge => true
            case _ => false
        }
    }

    func typeReferenceEdge(kind: EdgeKind): Bool {
        if (this.deriveTrait == DeriveTrait.PartialEqOrPartialOrd) {
            return considerDeriveEdge(kind)
        }
        return match (kind) {
            case EdgeKind.TypeReferenceEdge => true
            case _ => false
        }
    }

    func constrainComp(item: Item, comp: CompInfo): CanDerive {
        if (!this.canDeriveCompoundForwardDeclaration() && comp.isForwardDeclaration) {
            return CanDerive.No
        }
        if (!this.canDeriveCompoundWithDestructor() && this.ctx.hasDestructor(item.id)) {
            return CanDerive.No
        }
        if (comp.isUnion()) {
            if (this.canDeriveUnion()) {
                if (this.ctx.options.untaggedUnion &&
                    (!comp.templateParams.isEmpty() || !allTemplateParams(item.id, this.ctx).isEmpty())) {
                    return CanDerive.No
                }
            } else {
                if (this.ctx.options.untaggedUnion) {
                    return CanDerive.No
                }
                return CanDerive.Yes
            }
        }
        if (!this.canDeriveCompoundWithVtable() && this.ctx.hasVtable(item.id)) {
            return CanDerive.No
        }
        if (!this.canDeriveLargeArray() && this.hasTooLargeBitfieldUnit(comp) &&
            !item.isOpaque(this.ctx, ())) {
            return CanDerive.No
        }
        return this.constrainJoin(item) {kind => this.compEdge(kind)}
    }

    func constrainType(item: Item, ty: Type): CanDerive {
        if (!this.allowlistedItems.contains(item.id)) {
            return this.ctx.blocklistedTypeImplementsTrait(item, this.deriveTrait)
        }
        if (this.ctx.noDeriveByName(item, this.deriveTrait)) {
            return CanDerive.No
        }
        if (item.isOpaque(this.ctx, ())) {
            if (!this.canDeriveUnion() && ty.isUnion() && this.ctx.options.untaggedUnion) {
                return CanDerive.No
            }
            return CanDerive.Yes
        }
        if (let Some(instantiation) <- this.ctx.templateInstantiationFor(item.id)) {
            if (!hasMaterializedSpecializationBody(ty, instantiation)) {
                if (this.ctx.resolveItem(instantiation.definition).isOpaque(this.ctx, ())) {
                    return CanDerive.Yes
                }
                return this.constrainInstantiation(item.id, instantiation)
            }
        }

        return match (ty.kind) {
            case TypeKind.TypeKindVoid |
                TypeKind.TypeKindNullPtr |
                TypeKind.TypeKindInt(_) |
                TypeKind.TypeKindComplex(_) |
                TypeKind.TypeKindFloat(_) |
                TypeKind.TypeKindEnum(_) |
                TypeKind.TypeKindTypeParam |
                TypeKind.UnresolvedTypeRef(_, _, _) |
                TypeKind.TypeKindReference(_) |
                TypeKind.TypeKindObjCInterface(_) |
                TypeKind.TypeKindObjCId |
                TypeKind.TypeKindObjCSel => this.canDeriveSimple(ty.kind)
            case TypeKind.TypeKindPointer(inner) =>
                let innerType = this.ctx.resolveType(inner).canonicalType(this.ctx)
                match (innerType.kind) {
                    case TypeKind.TypeKindFunction(signature) => this.canDeriveFunctionPointer(signature)
                    case _ => this.canDerivePointer()
                }
            case TypeKind.TypeKindFunction(signature) => this.canDeriveFunctionPointer(signature)
            case TypeKind.TypeKindArray(inner, length) => this.constrainArray(inner, length)
            case TypeKind.TypeKindVector(inner, length) => this.constrainVector(inner, length)
            case TypeKind.TypeKindComp(comp) => this.constrainComp(item, comp)
            case TypeKind.ResolvedTypeRef(_) |
                TypeKind.TypeKindAlias(_) |
                TypeKind.TypeKindTemplateAlias(_, _) |
                TypeKind.TypeKindObjCBlockPointer(_) =>
                this.constrainJoin(item) {kind => this.typeReferenceEdge(kind)}
            case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
                this.constrainInstantiation(item.id, instantiation)
            case TypeKind.TypeKindOpaque => throw Exception("opaque type was not handled before derive dispatch")
        }
    }

    public func constrain(id: ItemId): ConstrainResult {
        if (this.resultFor(id) == CanDerive.No) {
            return ConstrainResult.Same
        }
        let item = this.ctx.resolveItem(id)
        var result = match (item.asType()) {
            case Some(ty) => this.constrainType(item, ty)
            case None => this.constrainJoin(item, considerDeriveEdge)
        }
        if (result == CanDerive.Yes && !this.canDeriveLargeArray()) {
            if (let Some(itemType) <- item.asType()) {
                if (let Some(layout) <- itemType.getLayout(this.ctx)) {
                    if (layout.align > DERIVE_ALIGNMENT_LIMIT) {
                        result = CanDerive.Manually
                    }
                }
            }
        }
        return this.insert(id, result)
    }
}

public func asCannotDeriveSet(results: HashMap<ItemId, CanDerive>): ItemSet {
    let items = ItemSet()
    for ((id, result) in results) {
        if (result != CanDerive.Yes) {
            items.add(id)
        }
    }
    return items
}

public func analyzeCanDerive(
    ctx: CjbindContext,
    items: ItemSet,
    deriveTrait: DeriveTrait
): HashMap<ItemId, CanDerive> {
    return analyze<ItemId, HashMap<ItemId, CanDerive>>(
        CannotDeriveAnalysis(ctx, items, deriveTrait)
    )
}
