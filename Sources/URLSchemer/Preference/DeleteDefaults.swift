public struct DeleteDefaults: Equatable {
    public let key: String

    public init(key: String) {
        self.key = key
    }
}

extension DeleteDefaults: SubjectVerbAction {
    public var module: Module { .preference }
    public var subject: String { key }
    public var verb: String { "delete" }
    public var payload: Payload? { nil }
}
