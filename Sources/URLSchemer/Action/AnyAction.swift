extension Action {
    @inlinable
    public func eraseToAnyAction() -> AnyAction<Self.Module, Self.Subject, Self.Verb, Self.Object>  {
        .init(self)
    }
}

public struct AnyAction<Module, Subject, Verb, Object>: Action {
    public let module: Module
    public let subject: Subject
    public let verb: Verb
    public let object: Object
    public let payload: Payload?

    public init(
        module: Module,
        subject: Subject,
        verb: Verb,
        object: Object,
        payload: Payload? = nil
    ) {
        self.module = module
        self.subject = subject
        self.verb = verb
        self.object = object
        self.payload = payload
    }

    @inlinable
    public func eraseToAnyAction() -> Self {
        self
    }
}

extension AnyAction where Self.Object == Void {
    @inlinable
    @inline(__always)
    public init(
        module: Module,
        subject: Subject,
        verb: Verb,
        payload: Payload? = nil
    ) {
        self.init(
            module: module,
            subject: subject,
            verb: verb,
            object: (),
            payload: payload
        )
    }
}

extension AnyAction {
    public init<A: Action>(_  action: A) 
    where A.Module == Self.Module, A.Subject == Self.Subject, A.Verb == Self.Verb, A.Object == Self.Object {
        self.init(
            module: action.module,
            subject: action.subject,
            verb: action.verb,
            object: action.object,
            payload: action.payload
        )
    }
}

extension AnyAction: Equatable
where Module: Equatable,
      Subject: Equatable,
      Verb: Equatable,
      Object: Equatable { }
