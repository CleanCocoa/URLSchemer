import Foundation

public struct ChangeDefaultsExecutor<Value: _UserDefaultsValue>: ActionExecutor {
    @usableFromInline
    let defaults: UserDefaults

    @inlinable
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    @inlinable
    public func execute(_ action: ChangeDefaults<Value>) {
        action.apply(to: defaults)
    }
}
