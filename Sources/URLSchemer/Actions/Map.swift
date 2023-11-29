extension SubjectVerbAction {
    @inlinable
    public func map<NewAction: SubjectVerbAction>(
        transform: @escaping (Self) -> NewAction
    ) -> Actions.Map<Self, NewAction> {
        .init(
            upstream: self,
            transform: transform
        )
    }
}

extension Actions {
    public struct Map<Upstream, NewAction>
    where Upstream: SubjectVerbAction, NewAction: SubjectVerbAction {
        public let upstream: Upstream
        public let transform: (Upstream) -> NewAction

        public init(
            upstream: Upstream,
            transform: @escaping (Upstream) -> NewAction
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        public func apply() -> NewAction {
            transform(upstream)
        }
    }
}
