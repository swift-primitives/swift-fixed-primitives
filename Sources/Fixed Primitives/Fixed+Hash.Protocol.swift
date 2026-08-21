public import Fixed_Primitive
public import Hash_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives

extension __Fixed: Hash.`Protocol`
where S: Span.`Protocol` & ~Copyable, S.Element: Hash.`Protocol` {

    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        span.hash(into: &hasher)
    }
}

extension __Fixed: Swift.Hashable
where S: Span.`Protocol` & ~Copyable, S.Element: Hash.`Protocol` {}
