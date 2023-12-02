import URLSchemer
import XCTest

final class FailTests: XCTestCase {
    func testWrapsCustomError() {
        XCTAssertThrowsError(
            try Fail<Void, ActionStub>(error: TestError(message: "custom error")).parse(())
        ) { error in
            switch error {
            case ActionParsingError.wrapping(let wrapped):
                XCTAssert(type(of: wrapped) == TestError.self)
                XCTAssertEqual("\(wrapped)", "custom error")
            default:
                XCTFail("Expected .wrapping error but got \(type(of: error))")
            }
        }
    }

    func testPassesActionParsingError() {
        XCTAssertThrowsError(
            try Fail<Void, ActionStub>(error: ActionParsingError.failed).parse(())
        ) { error in
            switch error {
            case ActionParsingError.failed:
                break // Happy path
            default:
                XCTFail("Expected ActionParsingError.failed but got \(type(of: error))")
            }
        }
    }
}
