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
    }

    public let mode: Mode
    public var module: Module {
        return switch mode {
        case .module(let module),
                .moduleSubject(let module, _),
                .moduleSubjectVerb(let module, _, _),
                .moduleSubjectVerbObject(let module, _, _, _):
            module
        }
    }
    public var subject: String? {
        return switch mode {
        case .module(_): nil
        case .moduleSubject(_, let subject),
                .moduleSubjectVerb(_, let subject, _),
                .moduleSubjectVerbObject(_, let subject, _, _):
            subject
        }
    }
    public var verb: String? {
        return switch mode {
        case .module(_), .moduleSubject(_, _): nil
        case .moduleSubjectVerb(_, _, let verb),
                .moduleSubjectVerbObject(_, _, let verb, _):
            verb
        }
    }
    public var object: String? {
        return switch mode {
        case .module(_), .moduleSubject(_, _), .moduleSubjectVerb(_, _, _): nil
        case .moduleSubjectVerbObject(_, _, _, let object):
            object
        }
    }
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
