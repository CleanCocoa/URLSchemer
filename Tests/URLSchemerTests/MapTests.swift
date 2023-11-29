import URLSchemer
import XCTest

final class MapTests: XCTestCase {
    func testMapAction() {
        let action = ActionStub(subject: "name")

        XCTAssertEqual(action.map { DeleteDefaults(key: $0.subject) }.apply(), DeleteDefaults(key: "name"))
    }
}
