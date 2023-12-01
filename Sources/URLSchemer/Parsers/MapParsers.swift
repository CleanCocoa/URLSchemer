extension ActionParser {
    /// Transforms the output of `self` to the input of `NewParser`, eagerly executing `transform` to produce `NewParser`.
    ///
    /// This is favorable over ``Lazy\map(_:)`` to not capture references strongly in an escaping lazy closure.
    @inlinable
    public func map<NewParser>(
        _ transform: () -> NewParser
    ) -> Parsers.MapParsers<Self, NewParser>
    where NewParser: ActionParser {
        .init(upstream: self, downstream: transform())
    }
}

extension Parsers {
    public struct MapParsers<Upstream: ActionParser, Downstream: ActionParser>
    where Upstream.Output == Downstream.Input {
        public typealias Input = Upstream.Input
        public typealias Output = Downstream.Output

        public let upstream: Upstream
        public let downstream: Downstream

        @inlinable
        public init(
            upstream: Upstream,
            downstream: Downstream
        ) {
            self.upstream = upstream
            self.downstream = downstream
        }

        @inlinable
        @inline(__always)
        public func parse(_ input: Input) rethrows -> Output {
            return try self.downstream.parse(self.upstream.parse(input))
        }
    }
}

// MARK: - Lazy

extension Lazy {
    /// Transforms the output of `self` to the input of `NewParser`, deferring execution until ``parse(_:)`` is called.
    @_disfavoredOverload
    @inlinable
    public func map<NewParser>(
        _ downstreamFactory: @escaping () -> NewParser
    ) -> Parsers.LazyMapParsers<Self.Base, NewParser>
    where NewParser: ActionParser {
        .init(upstream: self.base, downstreamFactory: downstreamFactory)
    }
}


extension Parsers {
    public struct LazyMapParsers<Upstream: ActionParser, Downstream: ActionParser>
    where Upstream.Output == Downstream.Input {
        public typealias Input = Upstream.Input
        public typealias Output = Downstream.Output

        public let upstream: Upstream
        public let downstreamFactory: () -> Downstream

        @inlinable
        public init(
            upstream: Upstream,
            downstreamFactory: @escaping () -> Downstream
        ) {
            self.upstream = upstream
            self.downstreamFactory = downstreamFactory
        }

        @inlinable
        @inline(__always)
        public func parse(_ input: Input) rethrows -> Output {
            return try self.downstreamFactory().parse(self.upstream.parse(input))
        }
    }

}
