// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Buffer_Protocol_Primitives
public import Index_Primitives
public import Store_Protocol_Primitives

// MARK: - Fixed (the always-full discipline over a non-growable COLUMN)

/// A fixed-count array that is always fully initialized — the thin, column-generic
/// always-full ADT.
///
/// `Fixed` carries exactly ONE invariant above its column: `count == capacity`, established
/// at construction and preserved by the surface (no remove/grow ops exist; `swap` and the
/// subscript replace in place). Everything else — element access, the mutation gate, the
/// Collection lattice — is the same seam-generic machinery as `Array<S>`.
///
/// The canonical column is the non-growable bounded buffer:
///
/// ```swift
/// __Fixed<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded>
/// ```
///
/// Copyability flows from the column: a `Shared`-wrapped bounded column yields a CoW
/// value-semantic fixed array with zero `Fixed`-side machinery.
///
/// ## Carrier (hoisted per [API-IMPL-009]/[PKG-NAME-006])
///
/// `__Fixed` is the bound-free carrier ([DS-025]): its column parameter `S` is bound
/// `~Copyable` **only**; every capability (observability, construction, element access,
/// the mutation gate) attaches by conditional `@inlinable` extension keyed on the seams
/// the column conforms. The PUBLIC spelling of the family is the front-door alias —
/// `Fixed<E>` (canonical) — declared in `Fixed.FrontDoor.swift` ([DS-028]); the hoisted
/// name never appears in consumer signatures.
@_documentation(visibility: public)
@frozen
public struct __Fixed<S: ~Copyable>: ~Copyable {

    /// The storage column.
    ///
    /// The always-full invariant (`count == capacity`) holds from construction onward.
    @usableFromInline
    package var store: S
}

// MARK: - Conditional Conformances

extension __Fixed: Copyable where S: Copyable {}

extension __Fixed: Sendable where S: Sendable & ~Copyable {}

// MARK: - Construction (seam-generic: wraps any FULL column)

extension __Fixed where S: ~Copyable, S: Store.`Protocol` & Buffer.`Protocol`,
    S.Count == Index_Primitives.Index<S.Element>.Count {
    /// Wraps an existing FULL column.
    ///
    /// - Precondition: `store.count == store.capacity` (the always-full invariant).
    @inlinable
    public init(store: consuming S) {
        precondition(store.count == store.capacity, "Fixed requires an always-full column")
        self.store = store
    }
}

// MARK: - Index

extension __Fixed where S: Store.`Protocol` & ~Copyable {
    /// Type-safe index for fixed-array elements, typed by the column's element.
    public typealias Index = Index_Primitives.Index<S.Element>
}
