package cjbind.ir

import std.collection.*

class AnalysisEdgeCollector <: Tracer {
    let edges = ArrayList<Edge>()

    public func visitKind(item: ItemId, kind: EdgeKind): Unit {
        this.edges.add(Edge(item, kind))
    }
}

func traceAnalysisEdges(ctx: CjbindContext, id: ItemId): Array<Edge> {
    let collector = AnalysisEdgeCollector()
    ctx.resolveItem(id).trace(ctx, collector, ())
    return collector.edges.toArray()
}

func reachableAnalysisItems(ctx: CjbindContext, roots: ItemSet): ItemSet {
    let reachable = ItemSet()
    for (id in ItemTraversal(ctx, analysisItemsToArray(roots))) {
        reachable.add(id)
    }
    return reachable
}

func addAnalysisDependency(
    dependencies: HashMap<ItemId, ArrayList<ItemId>>,
    prerequisite: ItemId,
    dependent: ItemId
): Unit {
    match (dependencies.get(prerequisite)) {
        case Some(items) => items.add(dependent)
        case None => dependencies.add(prerequisite, ArrayList<ItemId>([dependent]))
    }
}

func canonicalItemId(ctx: CjbindContext, start: ItemId): ItemId {
    let visited = ItemSet()
    var current = start
    while (visited.add(current)) {
        let item = match (ctx.resolveItemFallible(current)) {
            case Some(value) => value
            case None => return current
        }
        let ty = match (item.asType()) {
            case Some(value) => value
            case None => return current
        }
        match (ty.kind) {
            case TypeKind.TypeKindAlias(inner) => current = inner
            case TypeKind.TypeKindTemplateAlias(inner, _) => current = inner
            case TypeKind.ResolvedTypeRef(inner) => current = inner
            case _ => return current
        }
    }
    return current
}

func hasMaterializedSpecializationBody(
    ty: Type,
    instantiation: TemplateInstantiation
): Bool {
    if (instantiation.kind.isPrimary()) {
        return false
    }
    return match (ty.kind) {
        case TypeKind.TypeKindComp(_) => true
        case _ => false
    }
}

func normalFieldTypes(comp: CompInfo): Array<TypeId> {
    let result = ArrayList<TypeId>()
    match (comp.fields) {
        case CompFields.CompFieldsError => ()
        case CompFields.CompFieldsBefore(fields) =>
            for (field in fields) {
                if (field.bitfieldWidth.isNone()) {
                    result.add(field.ty)
                }
            }
        case CompFields.CompFieldsAfter(value) =>
            for (field in value.fields) {
                if (let Field.DataMember(data) <- field) {
                    result.add(data.ty)
                }
            }
    }
    return result.toArray()
}

func allFieldTypes(comp: CompInfo): Array<TypeId> {
    let result = ArrayList<TypeId>()
    match (comp.fields) {
        case CompFields.CompFieldsError => ()
        case CompFields.CompFieldsBefore(fields) =>
            for (field in fields) {
                result.add(field.ty)
            }
        case CompFields.CompFieldsAfter(value) =>
            for (field in value.fields) {
                match (field) {
                    case Field.DataMember(data) => result.add(data.ty)
                    case Field.Bitfields(unit) =>
                        for (bitfield in unit.bitfields) {
                            result.add(bitfield.data.ty)
                        }
                }
            }
    }
    return result.toArray()
}

func extendSet(target: ItemSet, source: ItemSet): Unit {
    for (id in source) {
        target.add(id)
    }
}

func usedSet(used: HashMap<ItemId, ItemSet>, id: ItemId): ItemSet {
    match (used.get(id)) {
        case Some(value) => value
        case None =>
            let value = ItemSet()
            used.add(id, value)
            value
    }
}
