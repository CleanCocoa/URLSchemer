/// `ActionParser` that uses its `Input` as output directly without any processing.
///
/// Use to inspect the raw input `AnyStringAction`, for example:
///
/// ```swift
/// let result: AnyStringAction = try components.parse { 
///     Passthrough()
/// }
/// ```
public struct Passthrough<Input: Action>: ActionParser, Sendable {
    public init() {}

    public func parse(_ input: Input) throws -> Input {
        input
    }
}
