extension Parsers {
    public struct Just<Output>: Parser {
        public typealias Input = Void

        @usableFromInline
        let generator: () -> Output

        @inlinable
        public init(_ output: @autoclosure @escaping () -> Output) {
            self.generator = output
        }

        @inlinable
        @inline(__always)
        public func parse(_ input: Void) -> Output {
            generator()
        }
    }
}

extension Parser where Input == Void {
    @inlinable
    @inline(__always)
    public func parse() rethrows -> Output {
        try parse(())
    }
}
