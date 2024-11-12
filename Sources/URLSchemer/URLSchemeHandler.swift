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
public final class URLSchemeHandler<Sink, Action>
where Sink: URLSchemer.Sink,
      Action: URLSchemer.Action,
      Sink.Action == Action,
      Action == AnyStringAction {

    /// `ActionParser` is a function that parses input from `URLComponents` to actions internally, then passes them on to its first parameter, `sink`.
    public typealias ActionParser = (
        _ actionFactory: @escaping (
            _ sink: Sink
        ) throws -> Void
    ) throws -> Void

    public typealias URLEventHandler = (
        _ event: NSAppleEventDescriptor,
        _ replyEvent: NSAppleEventDescriptor
    ) -> Void

    let actionParser: ActionParser
    let fallbackEventHandler: URLEventHandler?

    public init(
        actionParser: @escaping ActionParser,
        fallbackEventHandler: URLEventHandler? = nil
    ) {
        self.actionParser = actionParser
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
        guard let urlComponents = event.urlComponents else {
            fallbackEventHandler?(event, replyEvent)
            return
        }

        do {
            try actionParser { sink in
                try URLComponentsParser()
                    .parse(urlComponents)
                    .do(sink)
            }
        } catch {
            fallbackEventHandler?(event, replyEvent)
        }
    }
}

extension URLSchemeHandler where Sink == AnySink<AnyStringAction> {
    public typealias ParsedStringActionHandler = (AnyStringAction) throws -> Void

    @inlinable
    public convenience init(
        actionHandler: @escaping ParsedStringActionHandler,
        fallbackEventHandler: URLEventHandler? = nil
    ) {
        self.init(
            actionParser: { actionFactory in
                try actionFactory(AnySink(base: actionHandler))
            },
            fallbackEventHandler: fallbackEventHandler
        )
    }

}
