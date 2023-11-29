extension SubjectVerbAction {
    @inlinable
    public func eraseToAnySubjectVerbAction() -> AnySubjectVerbAction<Self.Subject, Self.Verb> {
        .init(self)
    }
}

public struct AnySubjectVerbAction<Subject, Verb>: SubjectVerbAction
{
    public let module: Module

    public let subject: Subject

    public let verb: Verb

    public let payload: Payload?

    @inlinable
    public init<Action>(_ action: Action)
    where Action: SubjectVerbAction, Action.Subject == Subject, Action.Verb == Verb {
        self.init(
            module: action.module,
            subject: action.subject,
            verb: action.verb,
            payload: action.payload
        )
    }

    @inlinable
    public init(
        module: Module,
        subject: @autoclosure () -> Subject,
        verb: @autoclosure () -> Verb,
        payload: Payload?
    ) {
        self.module = module
        self.subject = subject()
        self.verb = verb()
        self.payload = payload
    }

    @inlinable
    public func eraseToAnySubjectVerbAction() -> Self {
        self
    }
}

extension AnySubjectVerbAction: Equatable where Subject: Equatable, Verb: Equatable { }
