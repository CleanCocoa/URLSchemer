extension Action {
    @inlinable
    public func `do`<S>(_ sink: S)
    where S: Sink, S.A == Self {
        sink(self)
    }
}

public protocol Sink<A> {
    associatedtype A: Action

    func sink(_ action: A)
}

extension Sink {
    @inlinable
    public func callAsFunction(_ action: A) {
        sink(action)
    }
}
