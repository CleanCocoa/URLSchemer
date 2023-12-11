/// Parsed action with as many URL components as possible extracted into strings.
///
/// This is usually the first parsing step. Since URL components are string-based anyway, this transforms the unstructured URL into an expected format.
public struct StringAction: Action, Equatable {
    public let module: URLSchemer.Module
    public let subject: String
    public let verb: String

    public let object: String?

    public let payload: Payload?

    public init(
        module: Module,
        subject: String,
        verb: String,
        object: String? = nil,
        payload: Payload? = nil
    ) {
        self.module = module
        self.subject = subject
        self.verb = verb
        self.object = object
        self.payload = payload
    }
}

extension StringAction {
    /// Produces a copy of `self` with properties lowercased. Applies to ``Payload`` keys and values as well. Object is excempt because it's
    /// - Parameter includingObject: Controls whether ``object`` should be lowercased as well. Since this is the value to work with, that's not desirable most of the time.
    public func lowercased(
        includingObject: Bool = false
    ) -> Self {
        assert(module.rawValue == module.rawValue.lowercased(),
               "Module names are already lowercased for matching")
        return StringAction(
            module: module,
            subject: subject.lowercased(),
            verb: verb.lowercased(),
            object: includingObject ? object?.lowercased() : object,
            payload: payload?.lowercased()
        )
    }
}

extension Payload {
    /// Transforms the dictionary into a new dictionary with both keys and values lowercased.
    @inlinable
    public func lowercased() -> Self {
        map { ($0.lowercased(), $1?.lowercased()) }
    }
}

extension Dictionary {
    /// Transforms the dictionary into a new dictionary.
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an element tuple of this dictionary as `key` and `value` and returns a transformed tuple of the same or of different types.
    /// - Note: Every `key` from applying `transform`should be unique. Otherwise the last occurrence overwrites previous occurrences (the order is non-deterministic in dictionaries.).
    @inlinable
    public func map<NewKey, NewValue>(
        _ transform: ((key: Key, value: Value)) -> (NewKey, NewValue)
    ) -> [NewKey : NewValue] where NewKey: Hashable {
        return Dictionary<NewKey, NewValue>(self.map(transform), uniquingKeysWith: { _, last in last })
    }
}
