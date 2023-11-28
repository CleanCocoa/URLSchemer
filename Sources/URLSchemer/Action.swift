public struct Action {
    public let module: Module
    public let subject: String
    public let verb: String
    public let object: String?
    public let payload: Dictionary<String, String>?
}
