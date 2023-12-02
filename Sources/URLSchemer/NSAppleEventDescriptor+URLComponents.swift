import AppKit

extension NSAppleEventDescriptor {
    @usableFromInline
    var urlComponents: URLComponents? {
        guard let urlString = self.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue 
        else { return nil }
        return URLComponents(string: urlString)
    }
}
