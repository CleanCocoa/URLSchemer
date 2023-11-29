@rethrows public protocol Parser<Input, Output> {
    associatedtype Input
    associatedtype Output: Action

    func parse(_ input: Input) throws -> Output
}
