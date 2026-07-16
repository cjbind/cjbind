package cjbind_ffi

@C
public struct LinkedList {
    public var next: CPointer<UInt8>
    public var prev: CPointer<LinkedList>
    private init(next: CPointer<UInt8>, prev: CPointer<LinkedList>) {
        this.next = next
        this.prev = prev
    }
}

@C
public struct InstantiateIt {
    public let m_list: LinkedList_open0_int_close0
    private init(m_list: LinkedList_open0_int_close0) {
        this.m_list = m_list
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InstantiateIt>()
        if (size != 16) {
            throw Exception("Size of InstantiateIt is not 16 but ${size} bytes")
        }
        let align = alignOf<InstantiateIt>()
        if (align != 8) {
            throw Exception("Alignment of InstantiateIt is not 8 but ${align} bytes")
        }
}

@C
public struct LinkedList_open0_int_close0 {
    public var next: CPointer<LinkedList_open0_int_close0>
    public var prev: CPointer<LinkedList_open0_int_close0>
    private init(next: CPointer<LinkedList_open0_int_close0>, prev: CPointer<LinkedList_open0_int_close0>) {
        this.next = next
        this.prev = prev
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<LinkedList_open0_int_close0>()
        if (size != 16) {
            throw Exception("Size of LinkedList_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<LinkedList_open0_int_close0>()
        if (align != 8) {
            throw Exception("Alignment of LinkedList_open0_int_close0 is not 8 but ${align} bytes")
        }
}
