import AppKit

/// Convenience type to register as the `NSAppleEventManager`'s URL scheme event handler.
///
/// Use this if your app doesn't register e.g. its `AppDelegate` to handle URL schemes already:
///
///     let urlSchemeHandler = URLSchemeHandler()
///     urlSchemeHandler.install(onEventManager: NSAppleEventManager.shared())
///     // No need to keep a strong reference after this point.
///
/// You can also use the shorthand `URLSchemeHandler().install()`.
public final class URLSchemeHandler {
    public typealias ActionHandler = (Action) -> Void
    public typealias URLEventHandler = (_ event: NSAppleEventDescriptor, _ replyEvent: NSAppleEventDescriptor) -> Void

    let actionHandler: ActionHandler
    let fallbackEventHandler: URLEventHandler?

    public init(
        actionHandler: @escaping ActionHandler,
        fallbackEventHandler: URLEventHandler? = nil
    ) {
        self.actionHandler = actionHandler
        self.fallbackEventHandler = fallbackEventHandler
    }

    public func install(onEventManager eventManager: NSAppleEventManager = NSAppleEventManager.shared()) {
        eventManager.setEventHandler(
            self,
            andSelector: #selector(URLSchemeHandler.handle(getUrlEvent:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL))
    }

    @objc func handle(
        getUrlEvent event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        if let urlComponents = event.urlComponents,
           let action = Action(urlComponents: urlComponents) {
            actionHandler(action)
        } else {
            fallbackEventHandler?(event, replyEvent)
        }
    }
}
