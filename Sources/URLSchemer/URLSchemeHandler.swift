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

public enum FallbackReason {
    case missingURLComponents(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)
    case parsingError(Error, event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)
    case sinkError(Error, event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)
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
public final class URLSchemeHandler<Sink, Action, Parser>
where Sink: URLSchemer.Sink,
      Action: URLSchemer.Action,
      Sink.Action == Action,
      Parser: AnyStringActionParser<Action>
{
    public typealias FallbackEventHandler = (
        _ reason: FallbackReason
    ) -> Void

    let parser: Parser
    let sink: Sink
    let fallbackEventHandler: FallbackEventHandler?
    private var forwarder: GetURLAppleEventHandlerForwarder?

    public init(
        parser: Parser,
        sink: Sink,
        fallbackEventHandler: FallbackEventHandler? = nil
    ) {
        self.parser = parser
        self.sink = sink
        self.fallbackEventHandler = fallbackEventHandler
    }
}

extension URLSchemeHandler {
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
            fallbackEventHandler?(.missingURLComponents(event: urlEvent, replyEvent: replyEvent))
            return
        }

        let action: Action
        do {
            action = try self.parser.parse(URLComponentsParser().parse(urlComponents))
        } catch {
            fallbackEventHandler?(.parsingError(error, event: urlEvent, replyEvent: replyEvent))
            return
        }

        do {
            try sink.sink(action)
        } catch {
            fallbackEventHandler?(.sinkError(error, event: urlEvent, replyEvent: replyEvent))
        }
    }
}

extension URLSchemeHandler where Sink == AnySink<AnyStringAction>, Parser == Passthrough<AnyStringAction> {
    @inlinable
    public convenience init(
        actionHandler: @escaping (AnyStringAction) -> Void,
        fallbackEventHandler: FallbackEventHandler? = nil
    ) {
        self.init(
            parser: Passthrough(),
            sink: AnySink(base: actionHandler),
            fallbackEventHandler: fallbackEventHandler
        )
    }
}

extension URLSchemeHandler where Sink == AnyThrowingSink<AnyStringAction>, Parser == Passthrough<AnyStringAction> {
    @inlinable
    public convenience init(
        actionHandler: @escaping (AnyStringAction) throws -> Void,
        fallbackEventHandler: FallbackEventHandler? = nil
    ) {
        self.init(
            parser: Passthrough(),
            sink: AnyThrowingSink(base: actionHandler),
            fallbackEventHandler: fallbackEventHandler
        )
    }
}
