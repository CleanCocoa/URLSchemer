struct TestError: Error {
    var message = "test error"
}

extension TestError {
    init(_ message: String) {
        self.init(message: message)
    }
}

extension TestError: CustomDebugStringConvertible {
    @usableFromInline
    var debugDescription: String { message }
}
