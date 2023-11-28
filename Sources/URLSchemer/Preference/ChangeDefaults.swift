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
