extension SubjectVerbAction {
    @inlinable
    public func map<NewSubject, NewVerb>(
        transformSubject: @escaping (Self.Subject) -> NewSubject,
        transformVerb: @escaping (Self.Verb) -> NewVerb
    ) -> Actions.UnaryMap<Self, NewSubject, NewVerb> {
        .init(
            upstream: self,
            transformSubject: transformSubject,
            transformVerb: transformVerb
        )
    }

    @inlinable
    public func map<NewSubject>(
        transformSubject: @escaping (Self.Subject) -> NewSubject
    ) -> Actions.UnaryMap<Self, NewSubject, Self.Verb> {
        .init(
            upstream: self,
            transformSubject: transformSubject
        )
    }

    @inlinable
    public func map<NewVerb>(
        transformVerb: @escaping (Self.Verb) -> NewVerb
    ) -> Actions.UnaryMap<Self, Self.Subject, NewVerb> {
        .init(
            upstream: self,
            transformVerb: transformVerb
        )
    }
}

extension Actions {
    public struct UnaryMap<Upstream, NewSubject, NewVerb>: SubjectVerbAction
    where Upstream: SubjectVerbAction {
        public let upstream: Upstream
        public let transformSubject: (Upstream.Subject) -> NewSubject
        public let transformVerb: (Upstream.Verb) -> NewVerb

        public var module: Module { upstream.module}
        public var subject: NewSubject { transformSubject(upstream.subject)}
        public var verb: NewVerb { transformVerb(upstream.verb) }
        public var payload: Payload? { upstream.payload }

        @inlinable
        init(
            upstream: Upstream,
            transformSubject: @escaping (Upstream.Subject) -> NewSubject,
            transformVerb: @escaping (Upstream.Verb) -> NewVerb
        ) {
            self.upstream = upstream
            self.transformSubject = transformSubject
            self.transformVerb = transformVerb
        }
    }
}

extension Actions.UnaryMap
where NewVerb == Upstream.Verb {
    @inlinable
    @inline(__always)
    init(
        upstream: Upstream,
        transformSubject: @escaping (Upstream.Subject) -> NewSubject
    ) {
        self.init(
            upstream: upstream,
            transformSubject: transformSubject,
            transformVerb: identity(_:)
        )
    }
}

extension Actions.UnaryMap
where NewSubject == Upstream.Subject {
    @inlinable
    @inline(__always)
    public init(
        upstream: Upstream,
        transformVerb: @escaping (Upstream.Verb) -> NewVerb
    ) {
        self.init(
            upstream: upstream,
            transformSubject: identity(_:),
            transformVerb: transformVerb
        )
    }
}
