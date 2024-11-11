import Foundation

extension Parsers {
    public typealias URLComponentsParser = URLSchemer.URLComponentsParser
}

extension URLComponents {
    @inlinable
    public static var parser: URLComponentsParser {
        .init()
    }
}

extension URLComponents {
    public func parse<Parsers: ActionParser, Output: Action>(
        @OneOfBuilder<AnyStringAction, Output> _ build: () -> Parsers
    ) rethrows -> Output
    where Parsers.Input == AnyStringAction, Parsers.Output == Output
    {
        return try Self.parse(self, build)
    }

    public static func parse<Parsers: ActionParser, Output: Action>(
        _ input: URLComponents,
        @OneOfBuilder<AnyStringAction, Output> _ build: () -> Parsers
    ) rethrows -> Output
    where Parsers.Input == AnyStringAction, Parsers.Output == Output
    {
        let combined = parser.flatMap {
            OneOf(build)
        }
        return try combined.parse(input)
    }
}

public struct URLComponentsParser: ActionParser, Sendable {
    @inlinable
    public init() { }

    @inlinable
    @inline(__always)
    public func parse(_ urlComponents: URLComponents) throws -> AnyStringAction {
        guard let host = urlComponents.host,
              !host.isEmpty,
              var pathComponents = urlComponents.pathComponents
        else { throw ActionParsingError.failed }

        let module = Module(host)
        let subject = pathComponents.popFirst()
        let verb = pathComponents.popFirst()
        let object = pathComponents.popFirst()
        let payload = Payload(fromQueryItems: urlComponents.queryItems)

        return AnyStringAction(module: module, subject: subject, verb: verb, object: object, payload: payload)
    }
}

extension URLComponents {
    /// Path components **without the leading `/`**.
    @inlinable
    public var pathComponents: [String]? {
        return self.url
            .map(\.pathComponents)
            .map{$0.dropFirst()}
            .map{Array($0)}
    }
}
