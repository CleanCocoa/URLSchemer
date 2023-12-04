import Foundation

public struct DeleteDefaultsExecutor: ActionExecutor {
    @usableFromInline
    let defaults: UserDefaults

    @inlinable
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    @inlinable
    @inline(__always)
    public func execute(_ action: DeleteDefaults) {
        action.apply(to: defaults)
    }
}
