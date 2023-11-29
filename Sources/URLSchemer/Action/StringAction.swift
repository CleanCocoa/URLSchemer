public struct StringAction: Action, Equatable {
    public let module: URLSchemer.Module
    public let subject: String
    public let verb: String

    public let object: String?

    public let payload: Payload?

    public init(
        module: Module,
        subject: String,
        verb: String,
        object: String? = nil,
        payload: Payload? = nil
    ) {
        self.module = module
        self.subject = subject
        self.verb = verb
        self.object = object
        self.payload = payload
    }
}
