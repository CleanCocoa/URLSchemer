import URLSchemer
import XCTest

final class AppControlParserTests: XCTestCase {
    func testTerminate() throws {
        let action = try URLComponentsParser().flatMap {
            AppControlParser()
        }.parse(XCTUnwrap(URLComponents(string: "example://app/control/terminate")))

        XCTAssertEqual(action, AppControlAction(.terminate))
    }
}
