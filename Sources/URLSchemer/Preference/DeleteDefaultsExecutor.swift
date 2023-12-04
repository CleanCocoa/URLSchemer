import Foundation

public struct DeleteDefaultsExecutor: ActionExecutor {
    @usableFromInline
    let defaults: UserDefaults

    @inlinable
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    @inlinable
    public func execute(_ action: DeleteDefaults) {
        action.apply(to: defaults)
    }
}
