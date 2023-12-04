public struct AppControlExecutor: ActionExecutor {
    @inlinable
    public init() { }

    @inlinable
    @inline(__always)
    public func execute(_ action: AppControlAction) {
        action.run()
    }
}
