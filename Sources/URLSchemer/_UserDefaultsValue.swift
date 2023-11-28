/// Marks types as compatible with `UserDefaults.set(_:forKey:)` serialization.
protocol _UserDefaultsValue: Equatable { 
    func save(in defaults: UserDefaults, key: String)
}

protocol _PrimitiveUserDefaultsValue: _UserDefaultsValue { }

extension _PrimitiveUserDefaultsValue {
    func save(in defaults: UserDefaults, key: String) {
        defaults.set(self, forKey: key)
    }
}

// MARK: - Type conformances

// MARK: Primitive types

extension Bool: _PrimitiveUserDefaultsValue { }

extension UInt64: _PrimitiveUserDefaultsValue { }
extension UInt32: _PrimitiveUserDefaultsValue { }
extension UInt16: _PrimitiveUserDefaultsValue { }
extension UInt8: _PrimitiveUserDefaultsValue { }

extension Int64: _PrimitiveUserDefaultsValue { }
extension Int32: _PrimitiveUserDefaultsValue { }
extension Int16: _PrimitiveUserDefaultsValue { }
extension Int8: _PrimitiveUserDefaultsValue { }

extension Double: _PrimitiveUserDefaultsValue { }
extension Float32: _PrimitiveUserDefaultsValue { }
// Note that `Float16` is not a valid property list object and will raise a `NSInvalidArgumentException` as of 2023-11-28.

extension String: _PrimitiveUserDefaultsValue { }

extension Data: _PrimitiveUserDefaultsValue { }

// MARK: Collections

//extension Dictionary: _UserDefaultsValue where Key == String, Value: _UserDefaultsValue { }
//extension Array: _UserDefaultsValue where Element: _UserDefaultsValue { }

// MARK: Optional

protocol _OptionalUserDefaultsValue: _UserDefaultsValue {
    associatedtype Wrapped
    var wrapped: Wrapped? { get }
}

extension Optional: _UserDefaultsValue where Wrapped: _UserDefaultsValue {
    func save(in defaults: UserDefaults, key: String) {
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
    func save(in defaults: UserDefaults, key: String) {
        defaults.set(self, forKey: key)
    }
}
extension Date: _PrimitiveUserDefaultsValue { }
