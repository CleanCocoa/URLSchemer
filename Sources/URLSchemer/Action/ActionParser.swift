@rethrows public protocol ActionParser<Input, Output>: Sendable {
    associatedtype Input: Sendable
    associatedtype Output: Action, Sendable

    func parse(_ input: Input) throws -> Output
}
