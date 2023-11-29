@rethrows public protocol ActionParser<Input, Output> {
    associatedtype Input
    associatedtype Output: Action

    func parse(_ input: Input) throws -> Output
}
