public struct DeleteDefaultsParser: ActionParser, Sendable {
    @inlinable
    public func parse(_ input: StringAction) throws -> DeleteDefaults {
        switch input.lowercased().moduleSubjectVerb() {
        case (.preference, let key, "delete"):
            return DeleteDefaults(key: key)
        default:
            throw ActionParsingError.failed
        }
    }
}
