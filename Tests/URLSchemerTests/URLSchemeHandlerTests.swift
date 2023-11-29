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
//    func testHandlingValidActions() throws {
//        let event = NSAppleEventDescriptor.urlSchemeEvent(string: "example://module/subject/verb/object")
//
//        let actionHandledExpectation = expectation(description: "actionHandler called")
//        let sut = URLSchemeHandler(
//            actionHandler: { parseAction in
//                try! parseAction { action in
//                    XCTAssertEqual(
//                        action,
//                        StringAction(module: "module", subject: "subject", verb: "verb", object: "object"))
//                    actionHandledExpectation.fulfill()
//                }
//            },
//            fallbackEventHandler: { _, _ in
//                XCTFail("unexpected fallback call")
//            }
//        )
//        sut.handle(getUrlEvent: event, withReplyEvent: .null())
//
//        wait(for: [actionHandledExpectation])
//    }
//
//    func testForwardingInvalidActions() throws {
//        let invalidURLEvent = NSAppleEventDescriptor.urlSchemeEvent(string: "url://is/insufficient?for=actions")
//        let replyEvent = NSAppleEventDescriptor.null()
//
//        let fallbackExpectation = expectation(description: "actionHandler called")
//        let sut = URLSchemeHandler(
//            actionHandler: { _ in
//                XCTFail("unexpected callback for invalid action")
//            },
//            fallbackEventHandler: {
//                XCTAssertIdentical($0, invalidURLEvent)
//                XCTAssertIdentical($1, replyEvent)
//                fallbackExpectation.fulfill()
//            }
//        )
//        sut.handle(getUrlEvent: invalidURLEvent, withReplyEvent: replyEvent)
//
//        wait(for: [fallbackExpectation])
//    }
}
