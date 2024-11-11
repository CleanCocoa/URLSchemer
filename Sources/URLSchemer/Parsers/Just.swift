extension Parsers {
    public typealias Just = URLSchemer.Just
}

public struct Just<Output>: ActionParser, Sendable
where Output: Action, Output: Sendable {
    public typealias Input = Void

    @usableFromInline
    let generator: @Sendable () -> Output

    @inlinable
    public init(_ output: @autoclosure @escaping @Sendable () -> Output) {
        self.generator = output
    }

    @inlinable
    @inline(__always)
    public func parse(_ input: Void) -> Output {
        generator()
    }
}

extension ActionParser where Input == Void {
    @inlinable
    @inline(__always)
    public func parse() rethrows -> Output {
        try parse(())
    }
}
