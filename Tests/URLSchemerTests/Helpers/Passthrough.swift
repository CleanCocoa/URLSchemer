import URLSchemer

/// `ActionParser` that uses its `Input` as output directly without any processing.
///
/// Use to inspect the raw input `AnyStringAction`, for example:
///
/// ```swift
/// let result: AnyStringAction = try components.parse { 
///     Passthrough()
/// }
/// ```
struct Passthrough<Input: Action>: ActionParser, Sendable {
    func parse(_ input: Input) throws -> Input {
        input
    }
}
