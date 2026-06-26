# Fixed Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

`Fixed<S>` — a column adapter that enforces the `count == capacity` invariant from construction onward, giving an always-full array over any `Store` / `Buffer` column.

---

## Quick Start

`Fixed<S>` wraps a storage column and proves, at the type level, that every slot is initialized: `count == capacity` is established at construction and preserved by the surface. There is no `append` or `remove` that could leave a hole — the only writes are in place (`subscript`, `swap`), so downstream code never has to handle the partially-filled case.

The pinned constructors build the canonical non-growable heap column for you and infer the column type, so the common case needs no column spelling:

```swift
import Fixed_Primitives
import Index_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration

// Build three slots, each initialized at construction — `count == capacity` is
// structural, so there is never a partially-filled state to handle.
var grid = Fixed(repeating: 0, count: Index<Int>.Count(3))

grid[0] = 10            // in-place replacement — the only kind of write Fixed allows
grid[2] = 30
grid.swap(at: 0, with: 2)

print(grid[0])                                   // 30
print(grid.count == grid.capacity)               // true  — always-full, by construction
print(grid.freeCapacity == Index<Int>.Count(0))  // true  — no slot left to grow into
```

The two `*_Standard_Library_Integration` imports come from `swift-tagged-primitives` and `swift-ordinal-primitives`; they let typed indices accept plain integer literals (`grid[0]`, `Index<Int>.Count(3)`). Add those packages alongside this one to use that syntax.

`Fixed` is conditionally `Copyable` and `Sendable` exactly when its backing column is, and it adds no storage of its own — the invariant is structural, not bookkeeping.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-fixed-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Fixed Primitives", package: "swift-fixed-primitives"),
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products over the `Store` / `Buffer` column primitives.

| Product | Target | Purpose |
|---------|--------|---------|
| `Fixed Primitive` | `Sources/Fixed Primitive/` | The `Fixed<S>` namespace and base type — the always-full column adapter and its `Fixed.Error`. |
| `Fixed Primitives` | `Sources/Fixed Primitives/` | Umbrella — the `Collection` / `Span` / `Equation` / `Hash` conformances and the pinned bounded-heap-column constructors; re-exports `Fixed Primitive`. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
