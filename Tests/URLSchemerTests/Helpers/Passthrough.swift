import URLSchemer

struct Passthrough<Input: Action>: ActionParser {
    func parse(_ input: Input) throws -> Input {
        input
    }
}
