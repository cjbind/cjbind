package cjbind.ir

extend Type {
    /// The layout of the emitted field type. Keep this separate from getLayout:
    /// Clang's alignment still determines source field offsets and bitfield gaps.
    func generatedLayout(ctx: CjbindContext): ?Layout {
        return generatedTypeLayout(ctx, this, ItemSet())
    }
}

func generatedReferencedLayout(ctx: CjbindContext, id: TypeId, visiting: ItemSet): ?Layout {
    if (!visiting.add(id)) {
        return None
    }
    try {
        return generatedTypeLayout(ctx, ctx.resolveType(id), visiting)
    } finally {
        visiting.remove(id)
    }
}

func generatedArrayLayout(ctx: CjbindContext, inner: TypeId, count: UIntNative, visiting: ItemSet): ?Layout {
    return match (generatedReferencedLayout(ctx, inner, visiting)) {
        case Some(element) => Some(Layout(element.size * Int32(count), element.align))
        case None => None
    }
}

func generatedTypeLayout(ctx: CjbindContext, ty: Type, visiting: ItemSet): ?Layout {
    return match (ty.kind) {
        // Cangjie aliases and single-field newtypes inherit the underlying
        // type's natural layout, including when C applied aligned(N) to a typedef.
        case TypeKind.TypeKindAlias(inner) => generatedReferencedLayout(ctx, inner, visiting)
        case TypeKind.ResolvedTypeRef(inner) => generatedReferencedLayout(ctx, inner, visiting)
        case TypeKind.TypeKindTemplateAlias(inner, _) => generatedReferencedLayout(ctx, inner, visiting)
        case TypeKind.TypeKindEnum(en) => match (en.repr) {
            case Some(inner) => generatedReferencedLayout(ctx, inner, visiting)
            case None => None
        }
        case TypeKind.TypeKindArray(inner, count) => generatedArrayLayout(ctx, inner, count, visiting)
        case TypeKind.TypeKindVector(inner, count) => generatedArrayLayout(ctx, inner, count, visiting)
        // Records are emitted with matching fields or a layout-sized opaque
        // blob. Pointers do not inherit their pointee's alignment.
        case _ => ty.getLayout(ctx)
    }
}
