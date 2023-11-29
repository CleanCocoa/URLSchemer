public protocol BinaryAction: UnaryAction {
    associatedtype Object
    var object: Object { get }
}
