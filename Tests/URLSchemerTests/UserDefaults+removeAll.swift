import Foundation

extension UserDefaults {
    func removeAll() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
    }
}
