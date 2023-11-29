public protocol SubjectVerbObjectAction: SubjectVerbAction {
    associatedtype Object
    var object: Object { get }
}
