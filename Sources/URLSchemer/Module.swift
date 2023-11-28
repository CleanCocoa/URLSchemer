public struct Module {
    public let name: String

    public init(_ moduleName: String) {
        self.name = moduleName
    }
}

extension Module: RawRepresentable {
    public var rawValue: String { name }

    public init(rawValue: String) {
        self.init(rawValue)
    }
}
