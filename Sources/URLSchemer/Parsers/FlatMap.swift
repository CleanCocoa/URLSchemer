extension ActionParser {
    /// Transforms the output of `self` to the input of `NewParser`, eagerly executing `transform` to produce `NewParser`.
    ///
    /// This is favorable over ``Lazy\map(_:)`` to not capture references strongly in an escaping lazy closure.
    @inlinable
    public func flatMap<NewParser>(
        _ transform: () -> NewParser
    ) -> Parsers.FlatMap<Self, NewParser>
    where NewParser: ActionParser {
        .init(upstream: self, downstream: transform())
    }
}

extension Parsers {
    public struct FlatMap<Upstream: ActionParser, Downstream: ActionParser>: Sendable
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
    public func flatMap<NewParser>(
        _ downstreamFactory: @escaping @Sendable () -> NewParser
    ) -> Parsers.LazyFlatMap<Self.Base, NewParser>
    where NewParser: ActionParser {
        .init(upstream: self.base, downstreamFactory: downstreamFactory)
    }
}


extension Parsers {
    public struct LazyFlatMap<Upstream: ActionParser, Downstream: ActionParser>: Sendable
    where Upstream.Output == Downstream.Input {
        public typealias Input = Upstream.Input
        public typealias Output = Downstream.Output

        public let upstream: Upstream
        public let downstreamFactory: @Sendable () -> Downstream

        @inlinable
        public init(
            upstream: Upstream,
            downstreamFactory: @escaping @Sendable () -> Downstream
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
