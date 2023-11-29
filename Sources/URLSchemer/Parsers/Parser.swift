@rethrows public protocol Parser<Input, Output> {
    associatedtype Input
    associatedtype Output

    func parse(_ input: Input) throws -> Output
}
