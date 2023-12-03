extension Parsers {
    public typealias OneOf = URLSchemer.OneOf
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

// MARK: - OneOf Result Builder

@resultBuilder
public enum OneOfBuilder<Input, Output> {
    @inlinable
    static public func buildBlock<Parser: ActionParser>(_ parser: Parser) -> Parser
    where Parser.Input == Input, Parser.Output == Output {
        parser
    }
}

// MARK: (Potentially infinite) block element DSL

extension OneOfBuilder {
    @inlinable
    public static func buildPartialBlock<Parser: ActionParser>(
        first: Parser
    ) -> Parser
    where Parser.Input == Input, Parser.Output == Output
    {
        first
    }

    @inlinable
    public static func buildPartialBlock<Parser1, Parser2>(
        accumulated: Parser1,
        next: Parser2
    ) -> OneOf2<Parser1, Parser2>
    where Parser1.Input == Input, Parser1.Output == Output,
          Parser2.Input == Input, Parser2.Output == Output
    {
        .init(accumulated, next)
    }

    public struct OneOf2<Parser1, Parser2>: ActionParser
    where Parser1: ActionParser, Parser2: ActionParser,
          Parser1.Input == Parser2.Input,
          Parser1.Output == Parser2.Output
    {
        public typealias Input = Parser1.Input
        public typealias Output = Parser1.Output

        public let parser1: Parser1
        public let parser2: Parser2

        @inlinable
        public init(_ parser1: Parser1, _ parser2: Parser2) {
            self.parser1 = parser1
            self.parser2 = parser2
        }

        @inlinable
        public func parse(_ input: Input) rethrows -> Output {
            do {
                return try self.parser1.parse(input)
            } catch {
                do {
                    return try self.parser2.parse(input)
                } catch {
                    throw ActionParsingError.failed
                }
            }
        }
    }
}
