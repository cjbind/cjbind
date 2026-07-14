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
    for (id in analysisInitialWorklist(ctx, roots)) {
        reachable.add(id)
    }
    return reachable
}

func analysisInitialWorklist(ctx: CjbindContext, roots: ItemSet): Array<ItemId> {
    let worklist = ArrayList<ItemId>()
    for (root in analysisItemsToArray(roots)) {
        worklist.add(root)
        for (edge in traceAnalysisEdges(ctx, root)) {
            worklist.add(edge.to)
        }
    }
    return worklist.toArray()
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

func analysisLayout(ty: Type, ctx: CjbindContext): ?Layout {
    if (let Some(layout) <- ty.layout) {
        return Some(layout)
    }

    return match (ty.kind) {
        case TypeKind.TypeKindComp(comp) => analysisCompLayout(comp, ctx)
        case TypeKind.TypeKindArray(inner, length) =>
            if (length == 0) {
                analysisLayout(ctx.resolveType(inner), ctx)
                    .map({layout => Layout(0, layout.align)})
            } else {
                None
            }
        case TypeKind.TypeKindPointer(_) =>
            let size = ctx.pointerWidth()
            Some(Layout(size, size))
        case TypeKind.ResolvedTypeRef(inner) => analysisLayout(ctx.resolveType(inner), ctx)
        case _ => None
    }
}

func analysisCompLayout(comp: CompInfo, ctx: CjbindContext): ?Layout {
    match (comp.kind) {
        case CompKind.CompKindStruct => return None
        case CompKind.CompKindUnion => ()
    }
    if (comp.isForwardDeclaration) {
        return None
    }

    let hasFields = match (comp.fields) {
        case CompFields.CompFieldsError => false
        case CompFields.CompFieldsBefore(fields) => !fields.isEmpty()
        case CompFields.CompFieldsAfter(value) => !value.fields.isEmpty()
    }
    if (!hasFields) {
        return None
    }

    var maxSize = Int32(0)
    var maxAlign = Int32(1)
    match (comp.fields) {
        case CompFields.CompFieldsError => ()
        case CompFields.CompFieldsBefore(fields) =>
            for (field in fields) {
                if (let Some(layout) <- analysisLayout(ctx.resolveType(field.ty), ctx)) {
                    maxSize = max(maxSize, layout.size)
                    maxAlign = max(maxAlign, layout.align)
                }
            }
        case CompFields.CompFieldsAfter(value) =>
            for (field in value.fields) {
                let layout = match (field) {
                    case Field.DataMember(data) => analysisLayout(ctx.resolveType(data.ty), ctx)
                    case Field.Bitfields(unit) => Some(unit.layout)
                }
                if (let Some(known) <- layout) {
                    maxSize = max(maxSize, known.size)
                    maxAlign = max(maxAlign, known.align)
                }
            }
    }
    return Some(Layout(maxSize, maxAlign))
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
