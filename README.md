# URLSchemer

Transforms custom URL scheme components into actions.

## Usage

First, register your custom module:

```swift
extension URLSchemer.Module {
    /// `://plugin/` URL scheme actions.
    static let plugin = Self("plugin")
}
```

Then install the `URLSchemeHandler` as the appropriate `NSAppleEventManager` event handler:

```swift
extension AppDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        URLSchemer.URLSchemeHandler { (action: StringAction) in
            switch action.moduleSubjectVerbObject() {
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
        }.install()
    }
}
```


