public import Buffer_Protocol_Primitives
public import Collection_Primitives
public import Fixed_Primitive
public import Iterable
public import Iterator_Chunk_Primitives
import Memory_Iterator_Primitives
public import Span_Protocol_Primitives
public import Store_Protocol_Primitives

extension __Fixed: Collection.`Protocol`
where S: Span.`Protocol` & Store.`Protocol` & Buffer.`Protocol` & ~Copyable {

    public typealias Element = S.Element
}

extension __Fixed: Collection.Access.Random
where S: Span.`Protocol` & Store.`Protocol` & Buffer.`Protocol` & ~Copyable {}

extension __Fixed: Collection.Bidirectional
where S: Span.`Protocol` & Store.`Protocol` & Buffer.`Protocol` & ~Copyable {}

extension __Fixed: Span.`Protocol` where S: Span.`Protocol` & ~Copyable {

    @inlinable
    public var span: Swift.Span<S.Element> {
        @_lifetime(borrow self)
        borrowing get {
            store.span
        }
    }
}

extension __Fixed: Iterable where S: Span.`Protocol` & ~Copyable {

    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Chunk<S.Element>
}

extension __Fixed where S: ~Copyable, S: Store.`Protocol` & Buffer.`Protocol` {

    @inlinable
    public var startIndex: Index { .zero }

    @inlinable
    public var endIndex: Index { count.map(Ordinal.init) }

    @inlinable
    public func index(after i: Index) -> Index { i.successor.saturating() }

    @inlinable
    public func index(before i: Index) -> Index {
        do {
            return try i.predecessor.exact()
        } catch {
            preconditionFailure("Fixed.index(before:) called on the start index")
        }
    }
}

extension __Fixed where S: ~Copyable, S: Store.`Protocol` & Buffer.`Protocol` {

    @inlinable
    public var count: Index.Count { store.count }

    @inlinable
    public var isEmpty: Bool { store.isEmpty }

    @inlinable
    public var capacity: Index.Count { store.capacity }

    @inlinable
    public var freeCapacity: Index.Count {
        store.capacity.subtract.saturating(store.count)
    }
}

extension __Fixed where S: ~Copyable, S: Store.`Protocol` & Buffer.`Protocol` {

    @inlinable
    public subscript(_ index: Index) -> S.Element {
        _read {
            precondition(index < count, "Index out of bounds")
            yield store[index]
        }
        _modify {
            precondition(index < count, "Index out of bounds")
            store.unshare()
            yield &store[index]
        }
    }

    @inlinable
    public func withElement<R>(at index: Index, _ body: (borrowing S.Element) -> R) -> R {
        precondition(index < count, "Index out of bounds")
        return body(store[index])
    }
}

extension __Fixed where S: ~Copyable, S.Element: Copyable, S: Store.`Protocol` & Buffer.`Protocol` {

    @inlinable
    public func element(at index: Index) -> S.Element? {
        guard index < count else { return nil }
        return store[index]
    }

    @inlinable
    public func element(
        at base: Index,
        offsetBy offset: Index.Offset
    ) -> S.Element? {
        let newIndex: Index
        do {
            newIndex = try base + offset
        } catch {
            return nil
        }
        guard newIndex < count else { return nil }
        return store[newIndex]
    }
}

extension __Fixed where S: ~Copyable, S: Store.`Protocol` & Buffer.`Protocol` {

    @inlinable
    public mutating func swap(at i: Index, with j: Index) {
        precondition(i < count && j < count, "Index out of bounds")
        guard i != j else { return }
        store.unshare()

        let tail = count.subtract.saturating(.one).map(Ordinal.init)
        var carry = store.move(at: tail)
        if i == tail {
            Swift.swap(&carry, &store[j])
        } else if j == tail {
            Swift.swap(&carry, &store[i])
        } else {
            Swift.swap(&carry, &store[i])
            Swift.swap(&carry, &store[j])
            Swift.swap(&carry, &store[i])
        }
        store.initialize(at: tail, to: carry)
    }
}
