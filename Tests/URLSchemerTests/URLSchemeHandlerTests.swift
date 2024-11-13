import XCTest
@testable import URLSchemer

extension AEReturnID { static var irrelevant: Self { 1 } }
extension AETransactionID { static var irrelevant: Self { 2 } }

extension NSAppleEventDescriptor {
    static func urlSchemeEvent(string: String) -> NSAppleEventDescriptor {
        let event = NSAppleEventDescriptor.appleEvent(
            withEventClass: AEEventClass(kInternetEventClass),
            eventID: AEEventID(kAEGetURL),
            targetDescriptor: nil,
            returnID: .irrelevant,
            transactionID: .irrelevant
        )
        event.setParam(
            NSAppleEventDescriptor(string: string),
            forKeyword: AEKeyword(keyDirectObject)
        )
        return event
    }
}

final class URLSchemeHandlerTests: XCTestCase {
    func testHandlingValidActions() throws {
        let event = NSAppleEventDescriptor.urlSchemeEvent(string: "example://module/subject/verb/object")
        let actionHandledExpectation = expectation(description: "actionParser called")
        let sut = URLSchemeHandler(
            actionHandler: { (stringAction: AnyStringAction) in
                XCTAssertEqual(
                    stringAction,
                    AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "object"))
                actionHandledExpectation.fulfill()
            },
            fallback: { _ in
                XCTFail("unexpected fallback call")
            }
        )

        sut.handle(urlEvent: event, replyEvent: .null())

        wait(for: [actionHandledExpectation], timeout: 1)
    }

    func testForwardingThrowingValidActions() throws {
        enum Forwarding: Error { case error }

        let originalEvent = NSAppleEventDescriptor.urlSchemeEvent(string: "example://module/subject/verb/object")
        let replyEvent = NSAppleEventDescriptor.null()
        let actionHandledExpectation = expectation(description: "actionParser called")
        let fallbackExpectation = expectation(description: "fallback called")
        let sut = URLSchemeHandler(
            actionHandler: { (stringAction: AnyStringAction) throws in
                XCTAssertEqual(
                    stringAction,
                    AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "object"))
                actionHandledExpectation.fulfill()
                throw Forwarding.error
            },
            fallback: { reason in
                switch reason {
                case .sinkError(Forwarding.error, event: let event, replyEvent: let reply):
                    XCTAssertIdentical(event, originalEvent)
                    XCTAssertIdentical(reply, replyEvent)
                default:
                    XCTFail("Expected forwarding sink error, got: \(reason)")
                }
                fallbackExpectation.fulfill()
            }
        )

        sut.handle(urlEvent: originalEvent, replyEvent: replyEvent)

        wait(for: [actionHandledExpectation, fallbackExpectation], timeout: 1)
    }

    func testForwardingFallthroughFromParser() throws {
        let originalEvent = NSAppleEventDescriptor.urlSchemeEvent(string: "example://module/subject/verb/object")
        let replyEvent = NSAppleEventDescriptor.null()
        let actionHandledExpectation = expectation(description: "actionParser called")
        let fallbackExpectation = expectation(description: "fallback called")
        let sut = URLSchemeHandler(
            actionHandler: { (stringAction: AnyStringAction) throws in
                XCTAssertEqual(
                    stringAction,
                    AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "object"))
                actionHandledExpectation.fulfill()
                throw Fallthrough()
            },
            fallback: { reason in
                switch reason {
                case let .fallthrough(urlComponents, event, reply):
                    XCTAssertEqual(urlComponents, {
                        var comps = URLComponents()
                        comps.scheme = "example"
                        comps.host = "module"
                        comps.path = "/subject/verb/object"
                        return comps
                    }())
                    XCTAssertIdentical(event, originalEvent)
                    XCTAssertIdentical(reply, replyEvent)
                default:
                    XCTFail("Expected fallthrough signal, got: \(reason)")
                }
                fallbackExpectation.fulfill()
            }
        )

        sut.handle(urlEvent: originalEvent, replyEvent: replyEvent)

        wait(for: [actionHandledExpectation, fallbackExpectation], timeout: 1)
    }


    func testForwardingInvalidActions() throws {
        let invalidURLEvent = NSAppleEventDescriptor.urlSchemeEvent(string: "url://?is=insufficient&for=actions")
        let replyEvent = NSAppleEventDescriptor.null()

        let fallbackExpectation = expectation(description: "fallback called")
        let sut = URLSchemeHandler(
            actionHandler: { _ in
                XCTFail("unexpected callback for invalid action")
            },
            fallback: { reason in
                switch reason {
                case .parsingError(ActionParsingError.failed, event: let event, replyEvent: let reply):
                    XCTAssertIdentical(event, invalidURLEvent)
                    XCTAssertIdentical(reply, replyEvent)
                default:
                    XCTFail("Expected ActionParsingError.failed, got: \(reason)")
                }

                fallbackExpectation.fulfill()
            }
        )
        sut.handle(urlEvent: invalidURLEvent, replyEvent: replyEvent)

        wait(for: [fallbackExpectation], timeout: 1)
    }
}
