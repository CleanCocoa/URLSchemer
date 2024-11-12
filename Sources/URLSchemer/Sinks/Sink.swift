extension Action {
    @inlinable
    public func `do`<S>(_ sink: S) rethrows
    where S: Sink, S.Action == Self {
        try sink(self)
    }
}

@rethrows public protocol Sink<Action> {
    associatedtype Action: URLSchemer.Action

    func sink(_ action: Action) throws
}

extension Sink {
    @inlinable
    public func callAsFunction(_ action: Action) rethrows {
        try sink(action)
    }
}
