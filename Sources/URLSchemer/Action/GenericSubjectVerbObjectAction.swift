/// Parsed command from a URL.
///
/// In the context of a `module`, the `subject` is transformed via `verb` using either `object` or `payload` or  both (for verbs representing binary operators), or nothing (unary operators).
///
/// So for example `myapp://amplifier/volume/set/11` applies to the `amplifier` module, `set`ting (verb) its `volume` (subject) to `11` (object). This is a binary operator like `=` in programming. A verb like `reset` or `delete` would be a unary operator and work without an object.
public protocol Action<Module, Subject, Verb, Object> {
    associatedtype Module
    associatedtype Subject
    associatedtype Verb
    associatedtype Object

    var module: Module { get }
    var subject: Subject { get }
    var verb: Verb { get }
    var object: Object { get }
    var payload: Payload? { get }
}
