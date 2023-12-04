import AppKit

public struct AppControlAction: Action, Equatable {
    public enum Command: Equatable {
        case terminate
    }

    @inlinable
    public var module: Module { .app }

    @inlinable
    public var subject: NSApplication { .shared }

    public let verb: Command

    @inlinable
    public var object: Optional<Never> { nil }

    @inlinable
    public var payload: Payload? { nil }

    @inlinable
    public init(_ verb: Command) {
        self.verb = verb
    }
}

extension AppControlAction: ParsableAction {
    public static func parser() -> AppControlParser {
        return AppControlParser()
    }
}
