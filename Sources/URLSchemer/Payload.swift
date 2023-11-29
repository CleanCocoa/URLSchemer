/// URL query parameter payload of key--value pairs.
///
/// Nullability of the value is a bit counter-intuitive. The value is `nil` only if there's no assignment operator in the query portion of the URL.
///
/// So given this query portion:
///
///     ?a=1&b=&c&d=4
///
/// you will get a ``Payload ``of this form:
///
/// ```swift
///  ["a" : "1",   // `a=1` in the query
///   "b" : "",    // `b=`
///   "c" : nil,   // `c`
///   "d" : "4"]   // `d=4`
/// ```
///
///
public typealias Payload = Dictionary<String, String?>
