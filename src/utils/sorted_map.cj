package cjbind.utils

import std.collection.{TreeMap, HashMap}

public class SortedMapIterator<K, V> <: Iterator<(K, V)> where K <: Hashable & Comparable<K> {
    private let val: Iterator<(Int64, V)>
    private let index: HashMap<Int64, K>

    init(val: TreeMap<Int64, V>, index: HashMap<Int64, K>) {
        this.val = val.iterator()
        this.index = index
    }

    public func next(): Option<(K, V)> {
        let opt = val.next()
        match (opt) {
            case Some(v) => Some((index.get(v[0]).getOrThrow(), v[1]))
            case None => None
        }
    }
}

public class SortedMap<K, V> <: Iterable<(K, V)> where K <: Hashable & Comparable<K> {
    private let val: TreeMap<Int64, V> = TreeMap()
    private let index: HashMap<Int64, K> = HashMap()
    private var indexAt: Int64 = 0

    public init() {}

    public func add(key: K, value: V): Unit {
        let i = indexAt
        indexAt++
        index.add(i, key)
        val.add(i, value)
    }

    public func iterator(): Iterator<(K, V)> {
        return SortedMapIterator(val, index)
    }
}
