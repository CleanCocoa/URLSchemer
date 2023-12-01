extension ActionParser {
    @inlinable
    @_disfavoredOverload
    public func map<NewAction: Action>(
        transform: @escaping (Self.Output) -> NewAction
    ) -> Parsers.Map<Self, NewAction> {
        .init(upstream: self, transform: transform)
    }
}

extension Parsers {
    /// - Note: If you need a throwing `transform` closure, use ``MapConversion`` instead with a ``ThrowingConversion``.
    public struct Map<Upstream: ActionParser, NewAction: Action>: ActionParser {
        public typealias Input = Upstream.Input

        public let upstream: Upstream
        public let transform: (Upstream.Output) -> NewAction

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (Upstream.Output) -> NewAction
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        @inline(__always)
        public func parse(_ input: Upstream.Input) rethrows -> NewAction {
            self.transform(try self.upstream.parse(input))
        }
    }
}
