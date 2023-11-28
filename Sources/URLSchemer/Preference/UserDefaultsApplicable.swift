import Foundation

public protocol UserDefaultsApplicable {
    func apply(to defaults: UserDefaults)
}

extension UserDefaults {
    @inlinable func apply(_ applicable: UserDefaultsApplicable) {
        applicable.apply(to: self)
    }
}

extension DeleteDefaults: UserDefaultsApplicable {
    public func apply(to defaults: UserDefaults) {
        defaults.removeObject(forKey: key)
    }
}

extension ChangeDefaults: UserDefaultsApplicable {
    public func apply(to defaults: UserDefaults) {
        value.save(in: defaults, key: key)
    }
}
