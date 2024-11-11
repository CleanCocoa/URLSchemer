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
        @OneOfBuilder<StringAction, Output> _ build: () -> Parsers
    ) rethrows -> Output
    where Parsers.Input == StringAction, Parsers.Output == Output
    {
        return try Self.parse(self, build)
    }

    public static func parse<Parsers: ActionParser, Output: Action>(
        _ input: URLComponents,
        @OneOfBuilder<StringAction, Output> _ build: () -> Parsers
    ) rethrows -> Output
    where Parsers.Input == StringAction, Parsers.Output == Output
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
    public func parse(_ urlComponents: URLComponents) throws -> StringAction {
        guard let host = urlComponents.host,
              var pathComponents = urlComponents.pathComponents,
              let subject = pathComponents.popFirst(),
              let verb = pathComponents.popFirst()
        else { throw ActionParsingError.failed }

        let object = pathComponents.popFirst()

        return StringAction(
            module: .init(host),
            subject: subject,
            verb: verb,
            object: object,
            payload: Payload(fromQueryItems: urlComponents.queryItems)
        )
    }

    @inlinable
    @inline(__always)
    public func parseAny(_ urlComponents: URLComponents) throws -> AnyStringAction {
        guard let host = urlComponents.host,
              var pathComponents = urlComponents.pathComponents
        else { throw ActionParsingError.failed }

        let module = Module(host)
        let subject = pathComponents.popFirst()
        let verb = pathComponents.popFirst()
        let object = pathComponents.popFirst()
        let payload = Payload(fromQueryItems: urlComponents.queryItems)

        return AnyStringAction(module: module, subject: subject, verb: verb, object: object, payload: payload)
//        switch (subject, verb) {
//        case let (.some(subject), .some(verb)):
//            return StringAction(module: module, subject: subject, verb: verb, object: object, payload: payload)
//        default:
//            return GenericStringAction(module: module, subject: subject, verb: verb, object: object, payload: payload)
//        }
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
