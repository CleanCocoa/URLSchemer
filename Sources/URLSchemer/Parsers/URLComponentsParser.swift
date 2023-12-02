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

public struct URLComponentsParser: ActionParser {
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
        let payloadPairs = urlComponents.queryItems?.map { ($0.name, $0.value) }

        return StringAction(
            module: .init(host),
            subject: subject,
            verb: verb,
            object: object,
            payload: payloadPairs.map(Dictionary.fromKeysAndValuesKeepingLatestValue())
        )
    }
}

extension Dictionary {
    // Flipped, curried version of `Dictionary(_:uniquingKeysWith:)`, providing the second parameter.
    @usableFromInline
    static func fromKeysAndValuesKeepingLatestValue<S>()
    -> (_ keysAndValues: S) -> Dictionary<Key, Value>
    where S : Sequence, S.Element == (Key, Value) {
        return { (keysAndValues: S) in
            Dictionary(keysAndValues, uniquingKeysWith: { _, latest in latest })
        }
    }
}

extension URLComponents {
    /// Path components **without the leading `/`**.
    @usableFromInline
    var pathComponents: [String]? {
        return self.url
            .map(\.pathComponents)
            .map{$0.dropFirst()}
            .map{Array($0)}
    }
}
