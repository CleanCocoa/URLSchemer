import AppKit

/// Exposes its closure to the Objective-C runtime for installation as an `NSAppleEventManager`'s handler.
@objc private final class GetURLAppleEventHandlerForwarder: NSObject {
    typealias Handler = (
        _ event: NSAppleEventDescriptor,
        _ replyEvent: NSAppleEventDescriptor
    ) -> Void

    let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    @objc func handle(
        getURLEvent event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        handler(event, replyEvent)
    }
}

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
      Sink.Action == Action
{
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
    private var forwarder: GetURLAppleEventHandlerForwarder?

    public init(
        actionParser: @escaping ActionParser,
        fallbackEventHandler: URLEventHandler? = nil
    ) {
        self.actionParser = actionParser
        self.fallbackEventHandler = fallbackEventHandler
    }
}

extension URLSchemeHandler where Action == AnyStringAction {
    public func install(onEventManager eventManager: NSAppleEventManager = NSAppleEventManager.shared()) {
        let forwarder = GetURLAppleEventHandlerForwarder { [unowned self] in
            self.handle(urlEvent: $0, replyEvent: $1)
        }
        self.forwarder = forwarder

        eventManager.setEventHandler(
            forwarder,
            andSelector: #selector(GetURLAppleEventHandlerForwarder.handle(getURLEvent:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL))
    }

    func handle(
        urlEvent: NSAppleEventDescriptor,
        replyEvent: NSAppleEventDescriptor
    ) {
        guard let urlComponents = urlEvent.urlComponents else {
            fallbackEventHandler?(urlEvent, replyEvent)
            return
        }

        do {
            try actionParser { sink in
                let action = try URLComponentsParser().parse(urlComponents)
                try sink.sink(action)
            }
        } catch {
            fallbackEventHandler?(urlEvent, replyEvent)
        }
    }
}

extension URLSchemeHandler where Sink == AnySink<AnyStringAction> {
    @inlinable
    public convenience init(
        actionHandler: @escaping (AnyStringAction) -> Void,
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

extension URLSchemeHandler where Sink == AnyThrowingSink<AnyStringAction> {
    @inlinable
    public convenience init(
        actionHandler: @escaping (AnyStringAction) throws -> Void,
        fallbackEventHandler: URLEventHandler? = nil
    ) {
        self.init(
            actionParser: { actionFactory in
                try actionFactory(AnyThrowingSink(base: actionHandler))
            },
            fallbackEventHandler: fallbackEventHandler
        )
    }
}
