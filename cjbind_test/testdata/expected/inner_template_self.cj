package cjbind_ffi

@C
public struct LinkedList {
    public let next: CPointer<LinkedList>
    public let prev: CPointer<LinkedList>
    public init(next: CPointer<LinkedList>, prev: CPointer<LinkedList>) {
        this.next = next
        this.prev = prev
    }
}

@C
public struct InstantiateIt {
    public let m_list: LinkedList
    public init(m_list: LinkedList) {
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
