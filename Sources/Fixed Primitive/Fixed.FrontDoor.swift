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

public import Buffer_Linear_Bounded_Primitive
public import Buffer_Linear_Primitive
public import Buffer_Primitive
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

// MARK: - Fixed<E> — the CANONICAL front door ([DS-028])

/// A fixed-count array that is always fully initialized, over the default column:
/// the non-growable, heap-allocated, move-only bounded buffer.
///
/// This is the canonical front-door alias ([DS-028]) — the sanctioned
/// [API-NAME-004] generic-instantiation exception that pins the default column so
/// consumers spell `Fixed<Element>`, never the carrier `__Fixed` or a full column.
/// The alias fully specializes: conformances, the pinned constructors, and
/// `~Copyable` elements all flow through it with zero forwarding and zero runtime
/// cost.
///
/// ```swift
/// let f = try Fixed<Int>(count: Index<Int>.Count(3)) { _ in 0 }
/// ```
///
/// No capacity-axis variant exists (the always-full discipline over a bounded
/// column already IS the capacity-fixed point, [DS-028]'s "axis-changing alias"
/// concept collapses here — there is nothing to change TO); the `Shared` (CoW)
/// and `Small`/`Inline` allocation variants are consumer-pulled and land as they
/// gain a live consumer in this package's own Sources/Tests.
public typealias Fixed<E: ~Copyable> =
    __Fixed<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded>
