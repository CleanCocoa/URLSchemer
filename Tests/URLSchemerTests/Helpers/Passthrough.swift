import URLSchemer

/// `ActionParser` that uses its `Input` as output directly without any processing.
///
/// Use to inspect the raw input `StringAction`, for example:
///
/// ```swift
/// let result: StringAction = try components.parse { 
///     Passthrough()
/// }
/// ```
struct Passthrough<Input: Action>: ActionParser, Sendable {
    func parse(_ input: Input) throws -> Input {
        input
    }
}
