@rethrows public protocol Parser<Input, Output> {
    associatedtype Input
    associatedtype Output: SubjectVerbAction

    func parse(_ input: Input) throws -> Output
}
