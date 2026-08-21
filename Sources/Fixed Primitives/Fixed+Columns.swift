public import Buffer_Linear_Bounded_Primitives
public import Buffer_Linear_Primitive
public import Buffer_Primitive
public import Fixed_Primitive
public import Index_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

extension __Fixed where S: ~Copyable {

    @inlinable
    public init<E: ~Copyable>(
        count: Index_Primitives.Index<E>.Count,
        initializingWith initializer: (Index_Primitives.Index<E>) -> E
    ) throws(__Fixed<S>.Error)
    where S == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded {
        guard count >= .zero else {
            throw .invalidCount(count)
        }
        self.init(__unchecked: (), count: count, initializingWith: initializer)
    }

    @inlinable
    public init<E: ~Copyable>(
        __unchecked: Void,
        count: Index_Primitives.Index<E>.Count,
        initializingWith initializer: (Index_Primitives.Index<E>) -> E
    )
    where S == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded {
        if count == .zero {
            self.init(
                store: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded(
                    minimumCapacity: .zero
                )
            )
            return
        }
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded(
            minimumCapacity: count,
            initializingCount: count,
            with: { ptr in
                for i in 0..<Int(bitPattern: count) {
                    let index = Index_Primitives.Index<E>(Ordinal(UInt(i)))
                    ptr.append(initializer(index))
                }
            }
        )
        self.init(store: buffer)
    }

    @inlinable
    public init<E>(repeating value: E, count: Index_Primitives.Index<E>.Count)
    where S == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded {
        self.init(__unchecked: (), count: count, initializingWith: { _ in value })
    }

    @inlinable
    public init<E: ~Copyable, Failure: Swift.Error>(
        capacity: Index_Primitives.Index<E>.Count,
        initializingWith initializer: (inout Swift.OutputSpan<E>) throws(Failure) -> Void
    ) throws(Failure)
    where S == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded {
        let buffer = try Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
            .Bounded(
                capacity: capacity,
                initializingWith: initializer
            )
        precondition(
            buffer.count == capacity,
            "Fixed.init(capacity:initializingWith:) requires the OutputSpan to be fully populated."
        )
        self.init(store: buffer)
    }
}

extension __Fixed where S: ~Copyable {

    @inlinable
    @_lifetime(&self)
    public mutating func mutableSpan<E: ~Copyable>() -> Swift.MutableSpan<E>
    where S == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded {
        store.mutableSpan
    }
}

@_spi(Unsafe)
extension __Fixed where S: ~Copyable {

    @unsafe
    @inlinable
    public func withUnsafeBufferPointer<E, R, Failure: Swift.Error>(
        _ body: (UnsafeBufferPointer<E>) throws(Failure) -> R
    ) throws(Failure) -> R
    where S == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded {
        try unsafe store.withUnsafeBufferPointer(body)
    }
}
