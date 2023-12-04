/// A change to a `UserDefaults` entry of `key` to `value`.
public struct ChangeDefaults<Value>
where Value: _UserDefaultsValue {
    public let key: String
    public let value: Value

    public init(
        _ key: String,
        changeTo value: Value
    ) {
        self.key = key
        self.value = value
    }
}

extension ChangeDefaults: Equatable where Value: Equatable { }

extension ChangeDefaults: Action {
    public var module: Module { .preference }
    public var subject: String { key }
    public var verb: String { "set" }
    public var object: Value { value }
    public var payload: Payload? { nil }

    public static func parser() -> ChangeDefaultsParser<Value> {
        ChangeDefaultsParser()
    }
}
