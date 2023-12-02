import URLSchemer
import XCTest

final class MapTests: XCTestCase {
    func testMapAction() throws {
        let action = Just(ActionStub(subject: "name"))
            .map { DeleteDefaults(key: $0.subject) }
            .parse()

        XCTAssertEqual(action, DeleteDefaults(key: "name"))
    }
}
