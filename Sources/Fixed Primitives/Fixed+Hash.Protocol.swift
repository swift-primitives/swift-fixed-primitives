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

public import Fixed_Primitive
public import Hash_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives

// MARK: - Hash.Protocol Conformance (span-keyed; span-vending columns)

extension __Fixed: Hash.`Protocol` where S: Span.`Protocol` & ~Copyable, S.Element: Hash.`Protocol` {
    /// Hashes the count and elements, in order, over the span.
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        span.hash(into: &hasher)
    }
}

#if swift(>=6.4)
    // Swift 6.4+ (SE-0499): `Hash.`Protocol`` refines `Swift.Hashable`, and a conditional
    // conformance to a refining protocol no longer implies the inherited `Swift.Hashable`
    // conformance — state it explicitly. The `hash(into:)` above witnesses it. Matches the
    // swift-product-primitives precedent.
    extension __Fixed: Swift.Hashable where S: Span.`Protocol` & ~Copyable, S.Element: Hash.`Protocol` {}
#endif
