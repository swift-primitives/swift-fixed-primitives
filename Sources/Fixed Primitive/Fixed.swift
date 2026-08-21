public import Buffer_Protocol_Primitives
public import Index_Primitives
public import Store_Protocol_Primitives

@_documentation(visibility: public)
@frozen
public struct __Fixed<S: ~Copyable>: ~Copyable {

    @usableFromInline
    package var store: S
}

extension __Fixed: Copyable where S: Copyable {}

extension __Fixed: Sendable where S: Sendable & ~Copyable {}

extension __Fixed where S: ~Copyable, S: Store.`Protocol` & Buffer.`Protocol` {

    @inlinable
    public init(store: consuming S) {
        precondition(store.count == store.capacity, "Fixed requires an always-full column")
        self.store = store
    }
}

extension __Fixed where S: Store.`Protocol` & ~Copyable {

    public typealias Index = Index_Primitives.Index<S.Element>
}
