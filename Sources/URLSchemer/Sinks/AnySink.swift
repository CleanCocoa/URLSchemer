/// Exposes a non-throwing closure as a ``Sink`` so that consuming types know this variant, annotated as `@rethrows` in ``Sink``, will not produce errors.
public struct AnySink<Action>: Sink
where Action: URLSchemer.Action {
    @usableFromInline
    let base: (Action) -> Void

    @inlinable
    public init(
        base: @escaping (Action) -> Void
    ) {
        self.base = base
    }

    @inlinable
    @inline(__always)
    public func sink(_ action: Action) {
        base(action)
    }
}
