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
        URLSchemer.URLSchemeHandler { actionFactory in
            do { 
                try actionFactory { action in
                    self.execute(action)
                }
            } catch ActionParsingError.failed {
                // URL was not recognized by any parser
            } catch {
                // Handle actual error
            }
 
        }.install()
    }
    
    private func execute(_ action: StringAction) {
        switch (action.module, action.subject, action.verb, action.object) {
        // Handle ://plugin/PLUGIN_NAME/run actions
        case (.plugin, _, "run", nil): 
            execute(pluginNamed: action.subject)
        
        // Handle ://preference/KEY/set/VALUE 
        // and ://preference/KEY/unset actions (built-in module)
        case (.preference, let key, "set", let value): 
            UserDefaults.standard.set(value, forKey: key)
        case (.preference, let key, "unset", nil):
            UserDefaults.standard.removeObject(forKey: key)
        
        default: break
        }
    }
}
```


