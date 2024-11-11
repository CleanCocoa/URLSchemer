extension Parsers {
    public typealias AppControlParser = URLSchemer.AppControlParser
}

public struct AppControlParser: ActionParser, Sendable {
    public typealias Input = AnyStringAction
    public typealias Output = AppControlAction

    @inlinable
    public init() { }

    @inlinable
    public func parse(_ input: AnyStringAction) throws -> AppControlAction {
        switch input.mode.lowercased() {
        case .moduleSubjectVerb(.app, "control", "terminate"): AppControlAction(.terminate)
        default: throw ActionParsingError.failed
        }
    }
}
