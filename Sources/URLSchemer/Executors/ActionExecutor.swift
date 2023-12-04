public protocol ActionExecutor {
    associatedtype Action: URLSchemer.Action

    func execute(_ action: Action)
}

@usableFromInline
enum ActionExecutionError: Error {
    case executorMismatch
}

extension ActionExecutor {
    @inlinable
    public func execute(_ action: any URLSchemer.Action) throws {
        guard let action = action as? Action else {
            throw ActionExecutionError.executorMismatch
        }
        self.execute(action)
    }
}
