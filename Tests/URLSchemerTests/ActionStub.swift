import URLSchemer

struct ActionStub: SubjectVerbObjectAction, Equatable {
    var module: Module = .init("module")
    var subject = "subject"
    var verb = "verb"
    var object: String = "object"
    var payload: Payload? = [:]
}
