public struct AppControlExecutor: ActionExecutor {
    public func execute(_ action: AppControlAction) {
        action.run()
    }
}
