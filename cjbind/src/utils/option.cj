package cjbind.utils

public func anySome<T>(v: Array<Option<T>>): Bool {
    for (i in v) {
        if (i.isSome()) {
            return true
        }
    }
    return false
}

public func anySomeValue<T>(v: Array<Option<T>>): ?T {
    for (i in v) {
        match (i) {
            case Some(v) => return v
            case None => continue
        }
    }
    return None
}
