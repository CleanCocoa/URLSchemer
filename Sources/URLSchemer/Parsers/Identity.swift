/// The identity function.
///
/// Its practical application is to transform an `(A) -> B` mapping operation to `(A) -> A`.
///
/// - Parameter value: A value.
/// - Returns: Just `value`.
@inlinable
@inline(__always)
public func identity<T>(_ value: T) -> T {
    value
}
