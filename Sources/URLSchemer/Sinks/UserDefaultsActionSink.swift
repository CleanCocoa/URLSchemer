import Foundation

public struct UserDefaultsActionSink<DefaultsAction>: Sink
where DefaultsAction: Action,
      DefaultsAction: UserDefaultsApplicable
{
    public let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    @inlinable
    @inline(__always)
    public func sink(_ action: DefaultsAction) {
        defaults.apply(action)
    }
}
