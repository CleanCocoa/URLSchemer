import Foundation

public struct ChangeDefaultsExecutor<Value: _UserDefaultsValue>: ActionExecutor {
    @usableFromInline
    let defaults: UserDefaults

    @inlinable
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    @inlinable
    @inline(__always)
    public func execute(_ action: ChangeDefaults<Value>) {
        action.apply(to: defaults)
    }
}
