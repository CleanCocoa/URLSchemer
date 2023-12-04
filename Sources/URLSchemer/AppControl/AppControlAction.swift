import AppKit

public struct AppControlAction: Equatable {
    public enum Command: Equatable {
        case terminate
    }

    public let command: Command

    @inlinable
    public init(_ command: Command) {
        self.command = command
    }
}

extension AppControlAction: Action {
    @inlinable public var module: Module { .app }
    @inlinable public var subject: NSApplication { .shared }
    @inlinable public var verb: Command { command }
    @inlinable public var object: Optional<Never> { nil }
    @inlinable public var payload: Payload? { nil }
}

extension AppControlAction: ParsableAction {
    public static func parser() -> AppControlParser {
        return AppControlParser()
    }
}
