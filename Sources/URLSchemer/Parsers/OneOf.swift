@resultBuilder
public enum OneOfBuilder<Input, Output> {
    @inlinable
    static public func buildBlock<Parser: ActionParser>(_ parser: Parser) -> Parser
    where Parser.Input == Input, Parser.Output == Output {
        parser
    }
}

/// Attempts to run each of its `parsers` until one succeeds, or fails if every parser inside fails.
///
/// ## Ordering is important
///
/// ``OneOf`` behaves like the cases in a `switch` statement: the first match wins.
///
/// So put the most specific parsers at the top, and the most generic at the bottom.
public struct OneOf<Input, Output, Parsers: ActionParser>: ActionParser
where Parsers.Input == Input, Parsers.Output == Output {
    public let parsers: Parsers

    @inlinable
    public init(
        input inputType: Input.Type = Input.self,
        output outputType: Output.Type = Output.self,
        @OneOfBuilder<Input, Output> _ build: () -> Parsers
    ) {
        self.parsers = build()
    }

    @inlinable
    public func parse(_ input: Input) rethrows -> Output {
        try self.parsers.parse(input)
    }
}
