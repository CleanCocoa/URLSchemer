/// Exposes a throwing closure as a ``Sink`` so that consuming types know this variant, annotated as `@rethrows` in ``Sink``, needs to handle errors.
public struct AnyThrowingSink<Action>: Sink
where Action: URLSchemer.Action {
    @usableFromInline
    let base: (Action) throws -> Void

    @inlinable
    public init(
        base: @escaping (Action) throws -> Void
    ) {
        self.base = base
    }

    @inlinable
    @inline(__always)
    public func sink(_ action: Action) throws {
        try base(action)
    }
}
