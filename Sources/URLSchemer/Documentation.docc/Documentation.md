# ``URLSchemer``

Transforms custom URL scheme components into actions.

## Overview

Register ``URLSchemeHandler`` as your app's main URL scheme handler to install intelligent parsing of URL actions, so that you can focus on writing expressive pattern-matching code.

```swift
// Define your own namespaces or modules.
extension URLSchemer.Module {
    /// `://plugin/` URL scheme actions.
    static let plugin = Self("plugin")
}

extension AppDelegate {
    private lazy var urlSchemeHandler = URLSchemer.URLSchemeHandler { action in
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

## Topics

### URL Actions

By default, you will interact with ``URLSchemeHandler`` as a convenient entry point to URL parsing into ``AnyStringAction`` values.

- ``URLSchemeHandler``
- ``URLComponentsParser``
- ``AnyStringAction``
- ``Action``

### Custom Parsing

You can also write your own parsers with the parser algebra:

- ``Parsers``
- ``Parsers/OneOf``
- ``Parsers/Map``
- ``Parsers/FlatMap``
- ``Parsers/Just``
- ``Parsers/Fail``
- ``Parsers/Lazy``
- ``DirectConversion``
- ``ThrowingConversion``

### Preference Parsing

`UserDefaults` handling via the ``Module/preference`` namespace is built-in:

- ``ChangeDefaults``
- ``DeleteDefaults``
