# URLSchemer

Transforms custom URL scheme components into actions.

## Usage

First, 'register' your custom module:

```swift
extension URLSchemer.Module {
    /// `://plugin/` URL scheme actions.
    static let plugin = Self("plugin")
}
```

Then install the `URLSchemeHandler` as the appropriate `NSAppleEventManager` event handler:

```swift
extension AppDelegate {
    private static let urlSchemeHandler: URLSchemer.URLSchemeHandler?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Self.urlSchemeHandler = URLSchemer.URLSchemeHandler { (action: StringAction) in
            // Lowercase 'key' and 'action', but keep casing of 'object'
            // to preserve it when setting e.g. a name in UserDefaults.
            switch action.lowercased(includingObject: false).moduleSubjectVerbObject() {
            // Handle ://plugin/PLUGIN_NAME/run actions
            case (.plugin, _, "run", nil):
                execute(pluginNamed: action.subject)

            // Handle ://preference/KEY/set/VALUE
            // and ://preference/KEY/unset actions (built-in module)
            case (.preference, let key, "set", .some(let value)):
                UserDefaults.standard.set(value, forKey: key)
            case (.preference, let key, "unset", nil):
                UserDefaults.standard.removeObject(forKey: key)

            default: break
            }
        }
        Self.urlSchemeHandler.install()
    }
}
```


## Privacy Manifest

The package declares usage of `UserDefaults` API for wrapper that makes the `://preference` part of the URL scheme work.


