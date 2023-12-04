extension Parsers {
    public typealias AppControlParser = URLSchemer.AppControlParser
}

public struct AppControlParser: ActionParser {
    public typealias Input = StringAction
    public typealias Output = AppControlAction

    @inlinable
    @inline(__always)
    public init() { }

    @inlinable
    @inline(__always)
    public func parse(_ input: StringAction) throws -> AppControlAction {
        switch input.lowercased().moduleSubjectVerb() {
        case (.app, "control", "terminate"): AppControlAction(.terminate)
        default: throw ActionParsingError.failed
        }
    }
}
