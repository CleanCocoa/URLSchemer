import URLSchemer
import XCTest

final class PayloadTests: XCTestCase {
    func testSubscript() {
        let payload = Payload(("foo", "bar"), ("fizz", nil))
        XCTAssertEqual(payload["foo"], .some(.some("bar")))
        XCTAssertEqual(payload["fizz"], .some(.none))
        XCTAssertEqual(payload["fab"], .none)
    }
}
