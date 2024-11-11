/// Parsed action with as many URL components as possible extracted into strings.
///
/// ``AnyStringAction/Mode`` depends on the depth of the URL components's path.
///
/// This is usually the first parsing step. Since URL components are string-based anyway, this transforms the unstructured URL into an expected format.
public struct AnyStringAction: Action, Equatable, Sendable {
    public enum Mode: Equatable, Sendable {
        case module(Module)
        case moduleSubject(Module, String)
        case moduleSubjectVerb(Module, String, String)
        case moduleSubjectVerbObject(Module, String, String, String)

        public var module: Module {
            switch self {
            case .module(let module),
                    .moduleSubject(let module, _),
                    .moduleSubjectVerb(let module, _, _),
                    .moduleSubjectVerbObject(let module, _, _, _):
                module
            }
        }
        public var subject: String? {
            switch self {
            case .module(_): nil
            case .moduleSubject(_, let subject),
                    .moduleSubjectVerb(_, let subject, _),
                    .moduleSubjectVerbObject(_, let subject, _, _):
                subject
            }
        }
        public var verb: String? {
            switch self {
            case .module(_), .moduleSubject(_, _): nil
            case .moduleSubjectVerb(_, _, let verb),
                    .moduleSubjectVerbObject(_, _, let verb, _):
                verb
            }
        }
        public var object: String? {
            switch self {
            case .module(_), .moduleSubject(_, _), .moduleSubjectVerb(_, _, _): nil
            case .moduleSubjectVerbObject(_, _, _, let object):
                object
            }
        }

    }

    public let mode: Mode
    public var module: Module { mode.module }
    public var subject: String? { mode.subject }
    public var verb: String? { mode.verb }
    public var object: String? { mode.object }

    public let payload: Payload?

    public init(
        mode: Mode,
        payload: Payload? = nil
    ) {
        self.mode = mode
        self.payload = payload
    }
}

extension AnyStringAction {
    /// Convenience initializer to infer ``Mode``.
    ///
    /// > Invariant: It is not possible to skip e.g. `subject` or `verb` but pass `object` in practice.
    @usableFromInline
    internal init(
        module: Module,
        subject: String? = nil,
        verb: String? = nil,
        object: String? = nil,
        payload: Payload? = nil
    ) {
        switch (subject, verb, object) {
        case let (.some(subject), .some(verb), .some(object)):
            self.mode = .moduleSubjectVerbObject(module, subject, verb, object)
        case let (.some(subject), .some(verb), .none):
            self.mode = .moduleSubjectVerb(module, subject, verb)
        case let (.some(subject), .none, _):
            self.mode = .moduleSubject(module, subject)
        case (.none, _, _):
            self.mode = .module(module)
        }
        self.payload = payload
    }
}

extension AnyStringAction {
    /// Produces a copy of `self` with properties lowercased. Applies to ``Payload`` keys and values as well.
    /// - Parameter includingObject: Controls whether ``object`` should be lowercased as well. Since this is the value to work with, that's not desirable most of the time.
    public func lowercased(
        includingObject: Bool = false
    ) -> Self {
        assert(module.rawValue == module.rawValue.lowercased(),
               "Module names are already lowercased for matching")
        return AnyStringAction(
            mode: mode.lowercased(includingObject: includingObject),
            payload: payload?.lowercased()
        )
    }
}

extension AnyStringAction.Mode {
    /// Produces a copy of `self` with properties lowercased.
    /// - Parameter includingObject: Controls whether ``object`` should be lowercased as well. Since this is the value to work with, that's not desirable most of the time.
    public func lowercased(
        includingObject: Bool = false
    ) -> Self {
        assert(module.rawValue == module.rawValue.lowercased(),
               "Module names are already lowercased for matching")
        return switch self {
        case .module(let module):
                .module(module)
        case .moduleSubject(let module, let subject):
                .moduleSubject(module, subject.lowercased())
        case .moduleSubjectVerb(let module, let subject, let verb):
                .moduleSubjectVerb(module, subject.lowercased(), verb.lowercased())
        case .moduleSubjectVerbObject(let module, let subject, let verb, let object):
                .moduleSubjectVerbObject(module, subject.lowercased(), verb.lowercased(), includingObject ? object.lowercased() : object)
        }
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
