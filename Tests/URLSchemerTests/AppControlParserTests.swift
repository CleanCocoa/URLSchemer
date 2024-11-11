import URLSchemer
import XCTest

final class AppControlParserTests: XCTestCase {
    func testTerminate() throws {
        let action = try XCTUnwrap(URLComponents(string: "example://app/control/terminate"))
            .parse { AppControlParser() }

        XCTAssertEqual(action, AppControlAction(.terminate))
    }
}
