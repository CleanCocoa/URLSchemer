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
        let actionHandler: URLSchemeHandler.ParsedStringActionHandler = { stringAction in
            XCTAssertEqual(
                stringAction,
                StringAction(module: "module", subject: "subject", verb: "verb", object: "object"))
            actionHandledExpectation.fulfill()
        }

        let sut = URLSchemeHandler(
            actionParser: { factory in
                XCTAssertNoThrow(try factory(actionHandler))
            },
            fallbackEventHandler: { _, _ in
                XCTFail("unexpected fallback call")
            }
        )
        sut.handle(getUrlEvent: event, withReplyEvent: .null())

        wait(for: [actionHandledExpectation], timeout: 1)
    }

    func testForwardingInvalidActions() throws {
        let invalidURLEvent = NSAppleEventDescriptor.urlSchemeEvent(string: "url://is/insufficient?for=actions")
        let replyEvent = NSAppleEventDescriptor.null()

        let fallbackExpectation = expectation(description: "actionParser called")
        let sut = URLSchemeHandler(
            actionParser: { factory in
                do {
                    try factory({ _ in
                        XCTFail("unexpected callback for invalid action")
                    })
                } catch {
                    switch error {
                    case ActionParsingError.failed:
                        throw error // Happy path   
                    default:
                        XCTFail("Unexpected error: \(error)")
                        throw error
                    }
                }
            },
            fallbackEventHandler: {
                XCTAssertIdentical($0, invalidURLEvent)
                XCTAssertIdentical($1, replyEvent)
                fallbackExpectation.fulfill()
            }
        )
        sut.handle(getUrlEvent: invalidURLEvent, withReplyEvent: replyEvent)

        wait(for: [fallbackExpectation], timeout: 1)
    }
}
