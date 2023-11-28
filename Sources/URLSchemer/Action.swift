/// Parsed command from a URL.
///
/// In the context of a `module`, the `subject` is transformed via `verb` using either `object` or `payload` or  both (for verbs representing binary operators), or nothing (unary operators).
///
/// So for example `myapp://amplifier/volume/set/11` applies to the `amplifier` module, `set`ting (verb) its `volume` (subject) to `11` (object). This is a binary operator like `=` in programming. A verb like `reset` or `delete` would be a unary operator and work without an object.
public struct Action: Equatable {
    public let module: Module
    public let subject: String
    public let verb: String

    public let object: String?

    public let payload: Dictionary<String, String?>?

    public init(
        module: Module,
        subject: String,
        verb: String,
        object: String? = nil,
        payload: Dictionary<String, String?>? = nil
    ) {
        self.module = module
        self.subject = subject
        self.verb = verb
        self.object = object
        self.payload = payload
    }
}
