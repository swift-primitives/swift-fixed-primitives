# Fixed Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-fixed-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-fixed-primitives/actions/workflows/ci.yml)

`Fixed<S>` — the always-full column adapter. It wraps any column (`S: Store.Protocol & Buffer.Protocol`) and enforces a single invariant from construction onward: **`count == capacity`**. A `Fixed` is a column that is full by definition — the shape you reach for when "every slot is initialized" is a type-level guarantee rather than a runtime check, so downstream code never has to handle the partially-filled case.

Construction asserts the invariant (`precondition(store.count == store.capacity)`) and the wrapper preserves it; there is no `append` that could leave a hole. `Fixed` is conditionally `Copyable` / `Sendable` exactly when its backing column is.

---

## Key Features

- **`count == capacity`, guaranteed** — the always-full invariant holds from construction, so consumers skip the not-yet-filled branch entirely.
- **Column-agnostic** — wraps any `Store.Protocol & Buffer.Protocol` column (heap, inline, shared, …).
- **`~Copyable` substrate** — move-only columns are wrapped without an implicit copy; copyability/sendability flow from the backing.
- **Zero added storage** — `Fixed` holds only the column; the invariant is structural, not bookkeeping.

---

## Quick Start

```swift
import Fixed_Primitives

// Promote a full column to a type that proves it is full.
let fixed = Fixed(store: fullColumn)   // precondition: fullColumn.count == fullColumn.capacity
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-fixed-primitives.git", branch: "main")
]
```

Add a product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Fixed Primitives", package: "swift-fixed-primitives")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Fixed Primitives` | Umbrella — re-exports the type and its error surface | Most consumers |
| `Fixed Primitive` | `Fixed<S>` — the always-full column adapter | Naming the type directly |

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Pending (nightly-toolchain follow-up) |

---

## Related Packages

- [`swift-store-primitives`](https://github.com/swift-primitives/swift-store-primitives) — `Store.Protocol`, the column capability `Fixed` wraps.
- [`swift-buffer-primitives`](https://github.com/swift-primitives/swift-buffer-primitives) — `Buffer.Protocol`, the logical-count capability `Fixed` requires.
- [`swift-column-primitives`](https://github.com/swift-primitives/swift-column-primitives) — `Column`, the canonical columns a `Fixed` is typically built over.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
