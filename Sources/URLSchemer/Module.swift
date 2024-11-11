public struct Module: Equatable, Sendable {
    /// Module name, corresponding to `URLComponents.scheme`. Strictly lowercased.
    public let name: String

    /// - Invariant: Lowercases `moduleName`.
    public init(_ moduleName: String) {
        self.name = moduleName.lowercased()
    }
}

extension Module: RawRepresentable {
    public var rawValue: String { name }

    /// - Invariant: Lowercases `rawValue`.
    public init(rawValue: String) {
        self.init(rawValue)
    }
}
