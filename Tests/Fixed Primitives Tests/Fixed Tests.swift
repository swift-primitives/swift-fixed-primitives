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
//
// The always-full discipline over the bounded heap column — moved verbatim from
// swift-array-primitives at the W5-1 extraction (G2 ruling).

import Buffer_Linear_Bounded_Primitive
import Buffer_Linear_Primitive
import Buffer_Primitive
import Fixed_Primitives
import Index_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
import Storage_Contiguous_Primitives
import Storage_Primitive
import Tagged_Primitives_Standard_Library_Integration
import Testing

/// The non-growable bounded column + the always-full discipline over it.
private typealias BoundedHeapColumn<E: ~Copyable> =
    Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Bounded

private typealias FixedArray<E: ~Copyable> = Fixed<BoundedHeapColumn<E>>

@Suite(.serialized)
struct FixedTests {

    @Test
    @_optimize(none)  // workaround: see file footer (SILBitfield Mem2Reg overflow)
    func `checked init populates every slot; properties hold`() throws {
        let f = try FixedArray<Int>(count: Index<Int>.Count(3)) { _ in 7 }
        let count = f.count
        #expect(count == Index<Int>.Count(3))
        let isEmpty = f.isEmpty
        #expect(!isEmpty)
        let free = f.freeCapacity
        #expect(free == Index<Int>.Count(0))  // always-full invariant
        let e1 = f.withElement(at: 1) { $0 }
        #expect(e1 == 7)
    }

    @Test
    @_optimize(none)  // workaround: see file footer (SILBitfield Mem2Reg overflow)
    func `repeating + subscript read-write + swap`() {
        var f = FixedArray<Int>(repeating: 1, count: Index<Int>.Count(3))
        f[0] = 10
        f[2] = 30
        f.swap(at: 0, with: 2)
        let e0 = f[0]
        let e2 = f[2]
        #expect(e0 == 30)
        #expect(e2 == 10)
        let opt = f.element(at: 1)
        #expect(opt == 1)
    }

    @Test
    @_optimize(none)  // workaround: see file footer (SILBitfield Mem2Reg overflow)
    func `OutputSpan init enforces full population and reads back via span`() {
        let f = FixedArray<Int>(capacity: Index<Int>.Count(3)) { span in
            span.append(1)
            span.append(2)
            span.append(3)
        }
        var sum = 0
        do {
            let span = f.span
            for i in 0..<span.count { sum += span[i] }
        }
        #expect(sum == 6)
    }

    @Test
    @_optimize(none)  // workaround: see file footer (SILBitfield Mem2Reg overflow)
    func `mutableSpan writes through; index defaults navigate`() throws {
        var f = try FixedArray<Int>(count: Index<Int>.Count(2)) { _ in 5 }
        do {
            var m = f.mutableSpan()
            m[1] = 50
        }
        let e1 = f[1]
        #expect(e1 == 50)
        var walked: [Int] = []
        var i = f.startIndex
        while i < f.endIndex {
            walked.append(f[i])
            i = f.index(after: i)
        }
        #expect(walked == [5, 50])
    }

    @Test
    func `move-only elements live in Fixed and tear down once`() throws {
        Probe.reset()
        do {
            let f = try FixedArray<Item>(count: Index<Item>.Count(2)) { _ in Item(9) }
            f.withElement(at: 0) { item in
                #expect(item.id == 9)
            }
            _ = consume f
        }
        let count = Probe.destroyedCount
        #expect(count == 2)
    }

    @Test
    @_optimize(none)  // workaround: see file footer (SILBitfield Mem2Reg overflow)
    func `Fixed equality and hashing are span-keyed and capacity-independent`() throws {
        let f1 = try FixedArray<Int>(count: Index<Int>.Count(3)) { _ in 7 }
        let f2 = try FixedArray<Int>(count: Index<Int>.Count(3)) { _ in 7 }
        let equal = (f1 == f2)  // Equation.Protocol over the span
        #expect(equal)
        var h1 = Hasher()
        var h2 = Hasher()
        f1.hash(into: &h1)
        f2.hash(into: &h2)
        #expect(h1.finalize() == h2.finalize())  // Hash.Protocol over the span

        var f3 = try FixedArray<Int>(count: Index<Int>.Count(3)) { _ in 7 }
        f3[1] = 8
        let diverged = (f1 != f3)
        #expect(diverged)
    }
}

/// Destruction recorder (the suite above is `.serialized`).
private enum Probe {
    nonisolated(unsafe) static var _destroyed: Int = 0
    static func reset() { unsafe _destroyed = 0 }
    static func record() { unsafe _destroyed += 1 }
    static var destroyedCount: Int { unsafe _destroyed }
}

private struct Item: ~Copyable {
    let id: Int
    init(_ id: Int) { self.id = id }
    deinit { Probe.record() }
}

// MARK: - `@_optimize(none)` workaround (release-config compiler bugs)
//
// TWO distinct Swift 6.3 `-O` bugs touch this suite. The split annotation above is
// DELIBERATE — do NOT "tidy" it by annotating every test, and do NOT annotate the
// move-only test. (Both backtraces reproduce on macOS-release AND Ubuntu-release; only
// `swift test` defaulting to `-Onone` makes a plain `swift test` look clean.)
//
// (1) Mem2Reg / OSSACompleteLifetime SILBitfield overflow — the build-blocker.
//     Under `-O` the inliner collapses the whole `@inlinable` ~Copyable / generic /
//     closure-bearing `Fixed<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>
//     .Linear.Bounded>` accessor+init chain into a test function; on the larger tests the
//     resulting deep nested-borrow graph overflows the per-function `SILBitfield` budget:
//       Assertion failed: (endBit <= numCustomBits ...), SILBitfield at SILBitfield.h:60
//       While running pass "Mem2Reg" on "<the @Test function>"   → signal 6.
//     `@_optimize(none)` keeps the inliner from collapsing the chain in, so no function
//     overflows. The crash site is the TEST function (the inlining sink), not any library
//     declaration — the library (Sources) is release-clean.
//
// (2) `@_optimize(none)` + `consume` of a move-only value SKIPS its element deinits.
//     Putting `@_optimize(none)` on `move-only elements live in Fixed and tear down once`
//     made its `Item` deinits not run at `-O` (`Probe.destroyedCount → 0`, not 2) — a
//     teardown miscompile of the NoOptimization-in-an-`-O`-build mode. That test does NOT
//     trigger bug (1) (too few inlined accessors), so it is LEFT UNANNOTATED and passes.
//     *** Do NOT add `@_optimize(none)` to any test that observes move-only element deinits
//     — it silently suppresses them. ***
//
// Behaviour-preserving (tests assert identical results; only codegen is unoptimized).
// Remove the annotations when bug (1) is fixed upstream; never annotate a deinit-observing
// test for bug (2). Dossier: swift-institute/Issues/swift-issue-fixed-release-compiler-crash.
