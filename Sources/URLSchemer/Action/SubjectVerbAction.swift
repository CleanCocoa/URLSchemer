public protocol SubjectVerbAction {
    associatedtype Subject
    associatedtype Verb

    var module: Module { get }
    var subject: Subject { get }
    var verb: Verb { get }
    var payload: Payload? { get }
}
