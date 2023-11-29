import Foundation

extension Action {
    init?(urlComponents: URLComponents) {
        guard let host = urlComponents.host,
              var pathComponents = urlComponents.pathComponents,
              let subject = pathComponents.popFirst(),
              let verb = pathComponents.popFirst()
        else { return nil }

        let object = pathComponents.popFirst()
        let payloadPairs = urlComponents.queryItems?.map { ($0.name, $0.value) }

        self.init(
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
    fileprivate static func fromKeysAndValuesKeepingLatestValue<S>()
    -> (_ keysAndValues: S) -> Dictionary<Key, Value>
    where S : Sequence, S.Element == (Key, Value) {
        return { (keysAndValues: S) in
            Dictionary(keysAndValues, uniquingKeysWith: { _, latest in latest })
        }
    }
}

extension URLComponents {
    /// Path components **without the leading `/`**.
    fileprivate var pathComponents: [String]? {
        return self.url.map { Array($0.pathComponents.dropFirst()) }
    }
}
