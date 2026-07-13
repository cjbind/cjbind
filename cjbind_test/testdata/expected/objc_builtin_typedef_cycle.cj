package cjbind_ffi

import std.collection.HashMap

foreign func objc_getClass(name: CString): CPointer<Unit>

foreign func sel_registerName(name: CString): CPointer<Unit>

foreign func objc_msgSend(): Unit

foreign func objc_msgSend_stret(): Unit

foreign func objc_retain(obj: CPointer<Unit>): CPointer<Unit>

foreign func objc_release(obj: CPointer<Unit>): Unit

foreign func objc_autorelease(obj: CPointer<Unit>): CPointer<Unit>

var _objcSelCache = HashMap<String, CPointer<Unit>>()

func cachedSel(name: String): CPointer<Unit> {
    if (let Some(sel) <- _objcSelCache.get(name)) {
        return sel
    }
    let cs = unsafe { LibC.mallocCString(name) }
    let sel = unsafe { sel_registerName(cs) }
    unsafe { LibC.free(cs) }
    _objcSelCache[name] = sel
    return sel
}

var _objcClsCache = HashMap<String, CPointer<Unit>>()

func cachedClass(name: String): CPointer<Unit> {
    if (let Some(cls) <- _objcClsCache.get(name)) {
        return cls
    }
    let cs = unsafe { LibC.mallocCString(name) }
    let cls = unsafe { objc_getClass(cs) }
    unsafe { LibC.free(cs) }
    _objcClsCache[name] = cls
    return cls
}

public interface IFoo {
    func foo(): CPointer<Unit>
}
