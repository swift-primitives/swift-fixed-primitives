// exports.swift
// Fixed Primitive declares the hoisted carrier `struct __Fixed<S: ~Copyable>` (the
// always-full ADT over an explicit COLUMN, [DS-025]) + the canonical front door
// `Fixed<E>` ([DS-028]) + `Fixed.Index`/`Fixed.Error` + the pinned column
// constructor. Per the exports-narrowing ruling (audit #9, 2026-06-10), nothing is
// re-exported: consumers import the column-vocabulary modules explicitly.
