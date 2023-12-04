extension Parsers {
    public typealias DeleteDefaultsParser = URLSchemer.DeleteDefaultsParser
}

public struct DeleteDefaultsParser: ActionParser {
    @inlinable
    @inline(__always)
    public init() { }

    @inlinable
    @inline(__always)
    public func parse(_ input: StringAction) throws -> DeleteDefaults {
        switch input.lowercased().moduleSubjectVerb() {
        case (.preference, let key, "delete"):
            return DeleteDefaults(key: key)
        default:
            throw ActionParsingError.failed
        }
    }
}
