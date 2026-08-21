public import Index_Primitives
public import Store_Protocol_Primitives

extension __Fixed where S: Store.`Protocol` & ~Copyable {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidCount(Index_Primitives.Index<S.Element>.Count)

        case indexOutOfBounds(
            index: Index_Primitives.Index<S.Element>,
            count: Index_Primitives.Index<S.Element>.Count
        )
    }
}
