protocol UnaryAction {
    associatedtype Subject
    associatedtype Verb

    var module: Module { get }
    var subject: Subject { get }
    var verb: Verb { get }
    var payload: Payload? { get }
}

protocol BinaryAction: UnaryAction {
    associatedtype Object
    var object: Object { get }
}

public typealias Action = GenericAction

/// Parsed command from a URL.
///
/// In the context of a `module`, the `subject` is transformed via `verb` using either `object` or `payload` or  both (for verbs representing binary operators), or nothing (unary operators).
///
/// So for example `myapp://amplifier/volume/set/11` applies to the `amplifier` module, `set`ting (verb) its `volume` (subject) to `11` (object). This is a binary operator like `=` in programming. A verb like `reset` or `delete` would be a unary operator and work without an object.
public struct GenericAction: Equatable, BinaryAction {
    public let module: Module
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
