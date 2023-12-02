public enum ActionParsingError: Error {
    /// Indicates that the parser could not apply to the provided input.
    case failed
    case wrapping(Error)
}

extension ActionParsingError: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        switch self {
        case .failed: "parsing failed"
        case .wrapping(let error): "\(error)"
        }
    }
}
