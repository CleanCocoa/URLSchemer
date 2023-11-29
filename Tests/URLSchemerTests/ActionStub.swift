import URLSchemer

struct ActionStub: Action, Equatable {
    var module: Module = .init("module")
    var subject = "subject"
    var verb = "verb"
    var object: String = "object"
    var payload: Payload? = [:]
}
