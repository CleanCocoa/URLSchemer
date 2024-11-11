import Foundation

/// URL query parameter payload of key--value pairs.
///
/// Nullability of the value is different to `Swift.Dictionary`: The value is `nil` only if there's no assignment operator in the query portion of the URL.
///
/// So given this query portion:
///
///     ?a=1&b=&c&d=4
///
/// you will get a ``Payload`` represented in this form:
///
/// ```swift
///  ["a" : "1",   // `a=1` in the query
///   "b" : "",    // `b=`
///   "c" : nil,   // `c`
///   "d" : "4"]   // `d=4`
/// ```
///
/// That means the key `c` is defined, but its value is `nil`
public struct Payload: Equatable, Sendable {
    public let data: Dictionary<String, String?>

    public init(data: Dictionary<String, String?>) {
        self.data = data
    }
}

extension Payload {
    public init(_ tuple: (String, String?), tuples: (String, String?) ...) {
        let tuples = CollectionOfOne(tuple) + tuples
        self.init(data: Dictionary(fromKeysAndValuesKeepingLatestValue: tuples))
    }
}

extension Payload: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String?)...) {
        self.init(data: Dictionary(fromKeysAndValuesKeepingLatestValue: elements))
    }
}

// MARK: From URLQueryItems

extension Payload {
    public init?(fromQueryItems queryItems: [URLQueryItem]?) {
        guard let queryItems else { return nil }
        let tuples = queryItems.map { ($0.name, $0.value) }
        self.init(data: Dictionary(fromKeysAndValuesKeepingLatestValue: tuples))
    }
}

extension Dictionary {
    /// Uniquing keys by keeping the latest occurrence of any key, discarding previous occurrences.
    ///
    /// Usage:
    ///
    /// ```
    /// let arrayOfTuples: [(Int, String)] = ...
    /// let dict: [Int: String] = Dictionary(fromKeysAndValuesKeepingLatestValue: arrayOfTuples)
    /// ```
    @inlinable
    init<S>(
        fromKeysAndValuesKeepingLatestValue keysAndValues: S
    ) where S : Sequence, S.Element == (Key, Value) {
        self.init(keysAndValues, uniquingKeysWith: { _, latest in latest })
    }
}

// MARK: Transformations

extension Payload {
    /// Transforms the dictionary into a new dictionary with both keys and values lowercased.
    ///
    /// > Warning: Every key should be unique in lowercased form. Otherwise the last occurrence overwrites previous occurrences (the order is non-deterministic in dictionaries).
    @inlinable
    public func lowercased() -> Payload {
        return Payload(data: data.map { ($0.lowercased(), $1?.lowercased()) })
    }
}

