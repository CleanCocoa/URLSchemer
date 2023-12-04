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

    @inlinable
    public func run() {
        switch command {
        case .terminate: subject.terminate(nil)
        }
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
    @inlinable
    @inline(__always)
    public static func parser() -> AppControlParser {
        return AppControlParser()
    }
}

extension AppControlAction: ExecutableAction {
    @inlinable
    @inline(__always)
    public static func executor() -> AppControlExecutor {
        AppControlExecutor()
    }
}
