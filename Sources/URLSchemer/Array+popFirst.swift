extension Array {
    /// Returns the `first` element and removes it from `self`.
    /// - Returns: `first` (head of the list), if any.
    /// - Complexity: O(n) because the remainder is converted to a new array.
    mutating func popFirst() -> Element? {
        defer { self = Array(dropFirst()) }
        return first
    }
}
