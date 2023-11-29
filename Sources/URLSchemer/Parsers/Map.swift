extension Parser {
    @inlinable
    public func map<NewAction: SubjectVerbAction>(
        transform: @escaping (Self.Output) -> NewAction
    ) -> Parsers.Map<Self, NewAction> {
        .init(upstream: self, transform: transform)
    }
}

extension Parsers {
    public struct Map<Upstream: Parser, Output: SubjectVerbAction>: Parser {
        public typealias Input = Upstream.Input

        public let upstream: Upstream
        public let transform: (Upstream.Output) -> Output

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (Upstream.Output) -> Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        @inline(__always)
        public func parse(_ input: Upstream.Input) rethrows -> Output {
            self.transform(try self.upstream.parse(input))
        }
    }
}
