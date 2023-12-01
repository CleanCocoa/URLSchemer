/// Wraps an `(Input) -> Output` closure so that the type system knows whether the call via ``apply(_:)`` will be throwing or not.
///
/// Use ``DirectConversion`` (non-throwing) or ``ThrowingConversion`` (throwing).
@rethrows public protocol Conversion<Input, Output> {
    associatedtype Input
    associatedtype Output
    func apply(_ input: Input) throws -> Output
}

public struct DirectConversion<Input, Output>: Conversion {
    public let transform: (Input) -> Output

    @inlinable
    public init(block: @escaping (Input) -> Output) {
        self.transform = block
    }

    @inlinable
    public func apply(_ input: Input) -> Output {
        return transform(input)
    }
}

public struct ThrowingConversion<Input, Output>: Conversion {
    public let transform: (Input) throws -> Output

    @inlinable
    public init(block: @escaping (Input) throws -> Output) {
        self.transform = block
    }

    @inlinable
    public func apply(_ input: Input) throws -> Output {
        return try transform(input)
    }
}
