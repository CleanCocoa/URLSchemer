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
    /// Incoming URL scheme action that doesn't have any path components.
    ///
    /// This can be e.g. an empty `myapp://` for mere app and window activation, or `myapp://?key=val` with query parameters. Either way, there's nothing to parse.
    case missingURLComponents(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)

    /// Signals that ``Fallthrough`` has been thrown from ``URLSchemeHandler``'s ``Sink`` to allow the fallback handler to process the raw event or `URLComponents`.
    case `fallthrough`(URLComponents, event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)

    /// Parsing the `event` for `URLComponetns` in the ``ActionParser`` failed with an error.
    case parsingError(Error, event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)

    /// Processing the `event` in a ``Sink`` failed with an error.
    case sinkError(Error, event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor)
}

/// Throw from ``Sink`` or action handler blocks in ``URLSchemeHandler`` initialization to signal that you don't want to consume but pass on the parsed event.
///
/// Example:
/// ```swift
/// URLSchemeHandler(
///     actionHandler: { action in
///         // ... act on some actions but then pass on everything:
///         throw Fallthrough()
///     },
///     fallback: { reason in
///         guard case .fallthrough(let urlComponents, _, _) = reason else { return }
///         processElsewhere(urlComponents)
///     }
/// )
/// ```
public struct Fallthrough: Error {
    public init() {}
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
        fallback: FallbackEventHandler? = nil
    ) {
        self.parser = parser
        self.sink = sink
        self.fallbackEventHandler = fallback
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
        } catch is Fallthrough {
            fallbackEventHandler?(.fallthrough(urlComponents, event: urlEvent, replyEvent: replyEvent))
        } catch {
            fallbackEventHandler?(.sinkError(error, event: urlEvent, replyEvent: replyEvent))
        }
    }
}

extension URLSchemeHandler where Sink == AnySink<AnyStringAction>, Parser == Passthrough<AnyStringAction> {
    /// Creates URL scheme handler with parser and sink to pass ``AnyStringAction`` to a non-throwing `actionHandler` for consumption.
    @inlinable
    public convenience init(
        actionHandler: @escaping (AnyStringAction) -> Void,
        fallback: FallbackEventHandler? = nil
    ) {
        self.init(
            parser: Passthrough(),
            sink: AnySink(base: actionHandler),
            fallback: fallback
        )
    }
}

extension URLSchemeHandler where Sink == AnyThrowingSink<AnyStringAction>, Parser == Passthrough<AnyStringAction> {
    /// Creates URL scheme handler with parser and sink to pass ``AnyStringAction`` to a throwing `actionHandler` for consumption.
    ///
    /// Permits throwing ``Fallthrough`` from `actionHandler` to pass parsed events on to `fallback`.
    @inlinable
    public convenience init(
        actionHandler: @escaping (AnyStringAction) throws -> Void,
        fallback: FallbackEventHandler? = nil
    ) {
        self.init(
            parser: Passthrough(),
            sink: AnyThrowingSink(base: actionHandler),
            fallback: fallback
        )
    }
}
