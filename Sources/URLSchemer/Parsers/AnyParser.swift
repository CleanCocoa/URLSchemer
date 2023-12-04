public struct AnyParser<Input> {
    // TODO: Use Conversion to preseve (non)-throwing semantics.
    @usableFromInline
    let block: (Input) throws -> any Action

    @inlinable
    public init(
        block: @escaping (Input) throws -> any Action
    ) {
        self.block = block
    }

    @inlinable
    public func parse(_ input: Input) throws -> any Action {
        return try block(input)
    }
}

extension AnyParser {
    @inlinable
    @inline(__always)
    public init<P: ActionParser>(
        _ parser: P
    ) where P.Input == Input {
        self.init { input in
            try parser.parse(input)
        }
    }
}

extension ActionParser {
    @inlinable
    @inline(__always)
    public func eraseToAnyParser() -> AnyParser<Self.Input> {
        .init(self)
    }
}
