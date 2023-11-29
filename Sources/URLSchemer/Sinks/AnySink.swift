public struct AnySink<A: Action>: Sink {
    @usableFromInline
    let base: (A) -> Void

    @inlinable
    public init(
        base: @escaping (A) -> Void
    ) {
        self.base = base
    }

    @inlinable
    @inline(__always)
    public func sink(_ action: A) {
        base(action)
    }
}
