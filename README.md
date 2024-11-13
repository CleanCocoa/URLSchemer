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
    private lazy var urlSchemeHandler = URLSchemeHandler { action in
        // Lowercase 'key' and 'action', but keep casing of 'object'
        // to preserve it when setting e.g. a name in UserDefaults.
        switch action.mode.lowercased(includingObject: false) {
        // Handle ://plugin/PLUGIN_NAME/run actions
        case .moduleSubjectVerb(.plugin, let subject, "run"):
            execute(pluginNamed: subject)

        // Handle ://preference/KEY/set/VALUE
        // and ://preference/KEY/unset actions (built-in module)
        case .moduleSubjectVerbObject(.preference, let key, "set", .some(let value)):
            UserDefaults.standard.set(value, forKey: key)
        case .moduleSubjectVerb(.preference, let key, "unset"):
            UserDefaults.standard.removeObject(forKey: key)

        default: break
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        urlSchemeHandler.install()
    }
}
```


## Privacy Manifest

The package declares usage of `UserDefaults` API for wrapper that makes the `://preference` part of the URL scheme work.


## License

Copyright &copy; 2023 Christian Tietze. Distributed under the MIT License.

