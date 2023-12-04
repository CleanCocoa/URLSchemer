public protocol FromURLComponentInitializable {
    init?(_fromURLComponent string: String)
}

/// Marks types as compatible with `UserDefaults.set(_:forKey:)` serialization.
public protocol _UserDefaultsValue: FromURLComponentInitializable {
    func save(in defaults: UserDefaults, key: String)
}

// The separation of `_PrimitiveUserDefaultsValue` from `_UserDefaultsValue` creates an extension point for arrays and dictionaries. Until we figure out how to represent these outside of query parameters in a URL without being overly weird, this is mostly a hint towards future changes and not of any immediate utility. That's why it's fileprivate for now.
fileprivate protocol _PrimitiveUserDefaultsValue: _UserDefaultsValue { }

extension _PrimitiveUserDefaultsValue {
    public func save(in defaults: UserDefaults, key: String) {
        defaults.set(self, forKey: key)
    }
}

// MARK: - Type conformances

// MARK: Primitive types

extension Bool: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}

extension UInt: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension UInt64: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension UInt32: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension UInt16: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension UInt8: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}

extension Int: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension Int64: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension Int32: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension Int16: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension Int8: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}

extension Double: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}
extension Float32: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string)
    }
}

// Note that `Float16` is not a valid property list object and will raise a `NSInvalidArgumentException` as of 2023-11-28.

extension String: _PrimitiveUserDefaultsValue { 
    public init?(_fromURLComponent string: String) {
        self = string
    }
}

extension Data: _PrimitiveUserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        self = data
    }
}

// MARK: Collections

// As mentioned above, there's potential to make collections UserDefaults persitable, but less so fit into a URL.
// extension Dictionary: _UserDefaultsValue where Key == String, Value: _UserDefaultsValue { }
// extension Array: _UserDefaultsValue where Element: _UserDefaultsValue { }

// MARK: Optional

protocol _OptionalUserDefaultsValue: _UserDefaultsValue {
    associatedtype Wrapped
    var wrapped: Wrapped? { get }
}

extension Optional: _UserDefaultsValue, FromURLComponentInitializable where Wrapped: _UserDefaultsValue & FromURLComponentInitializable {
    public init?(_fromURLComponent string: String) {
        self = Wrapped(_fromURLComponent: string)
    }

    public func save(in defaults: UserDefaults, key: String) {
        wrapped?.save(in: defaults, key: key)
    }
}

extension Optional: _OptionalUserDefaultsValue where Wrapped: _UserDefaultsValue {
    var wrapped: Wrapped? {
        return switch self {
            case .none: nil
            case .some(let wrapped): wrapped
        }
    }
}

// MARK: Foundation types

import Foundation

extension URL: _UserDefaultsValue {
    public init?(_fromURLComponent string: String) {
        self.init(string: string)
    }

    public func save(in defaults: UserDefaults, key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Date: _PrimitiveUserDefaultsValue { 
    public init?(_fromURLComponent string: String) {
        guard let timeInterval = TimeInterval(string) else { return nil }
        self.init(timeIntervalSince1970: timeInterval)
    }
}
