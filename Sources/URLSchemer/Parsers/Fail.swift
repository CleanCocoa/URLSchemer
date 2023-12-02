extension Parsers {
    public typealias Fail = URLSchemer.Fail
}

/// No matter the input, terminates with throwing a failure. Wraps custom errors in ``ActionParsingError`` if needed.
public struct Fail<Input, Output: Action>: ActionParser {
    @usableFromInline
    let error: ActionParsingError

    @inlinable
    public init(error: Error) {
        self.error = if let parsingError = error as? ActionParsingError {
            parsingError
        } else {
            ActionParsingError.wrapping(error)
        }
    }

    @inlinable
    public func parse(_ input: Input) throws -> Output {
        throw error
    }
}
