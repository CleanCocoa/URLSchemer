extension ActionParser {
    @inlinable
    @_disfavoredOverload
    public func map<NewAction: Action>(
        transform: @escaping @Sendable (Self.Output) throws -> NewAction
    ) -> Parsers.MapConversion<Self, ThrowingConversion<Self.Output, NewAction>> {
        .init(upstream: self, conversion: ThrowingConversion(block: transform))
    }

    @inlinable
    public func map<C: Conversion>(
        conversion: C
    ) -> Parsers.MapConversion<Self, C>
    where C.Input == Self.Output, C.Output: Action {
        .init(upstream: self, conversion: conversion)
    }
}

extension Parsers {
    /// Unlike ``Map``, by employing ``Conversion`` to wrap the transformation , you can have both throwing and non-throwing blocks, maintaining the `rethrows` semantics of ``ActionParser``.
    public struct MapConversion<Upstream: ActionParser, Downstream: Conversion>: ActionParser
    where Downstream.Input == Upstream.Output, Downstream.Output: Action {
        public typealias Input = Upstream.Input

        public let upstream: Upstream
        public let conversion: Downstream

        @inlinable
        public init(
            upstream: Upstream,
            conversion: Downstream
        ) {
            self.upstream = upstream
            self.conversion = conversion
        }

        @inlinable
        @inline(__always)
        public func parse(_ input: Upstream.Input) rethrows -> Downstream.Output {
            try self.conversion.apply(self.upstream.parse(input))
        }
    }
}

extension Parsers.MapConversion: Sendable where Upstream: Sendable, Downstream: Sendable { }
