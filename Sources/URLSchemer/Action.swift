public struct Action {
    public let module: String
    public let subject: String
    public let verb: String
    public let object: String?
    public let payload: Dictionary<String, String>?
}
