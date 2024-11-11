extension ActionParser {
    @inlinable
    var lazy: Lazy<Self> { .init(base: self) }
}

public struct Lazy<Parser>: Sendable
where Parser: ActionParser {
    public typealias Base = Parser
    public typealias Input = Parser.Input
    public typealias Output = Parser.Output

    public let base: Base

    @inlinable
    public init(base: Base) {
        self.base = base
    }
}
