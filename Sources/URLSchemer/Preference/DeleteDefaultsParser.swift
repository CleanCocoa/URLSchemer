public struct DeleteDefaultsParser: ActionParser, Sendable {
    @inlinable
    public func parse(_ input: AnyStringAction) throws -> DeleteDefaults {
        switch input.mode.lowercased() {
        case .moduleSubjectVerb(.preference, let key, "delete"):
            return DeleteDefaults(key: key)
        default:
            throw ActionParsingError.failed
        }
    }
}
