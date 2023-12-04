extension Parsers {
    public typealias ChangeDefaultsParser = URLSchemer.ChangeDefaultsParser
}

public struct ChangeDefaultsParser<Value: _UserDefaultsValue>: ActionParser {
    @inlinable
    @inline(__always)
    public init() { }

    @inlinable
    @inline(__always)
    public func parse(_ input: StringAction) throws -> ChangeDefaults<Value> {
        switch input.lowercased(includingObject: false).moduleSubjectVerbObject() {
        case (.preference, let key, "set", .some(let stringValue)):
            guard let value = Value(_fromURLComponent: stringValue) else {
                throw ActionParsingError.failed
            }
            return ChangeDefaults(key, changeTo: value)
        default:
            throw ActionParsingError.failed
        }
    }
}
