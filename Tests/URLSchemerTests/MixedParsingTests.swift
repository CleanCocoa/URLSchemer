import XCTest
import URLSchemer

final class AnyStringActionTests: XCTestCase {
    func testParsingMixed() throws {
        let parser = URLComponentsParser()
        let actions: [AnyStringAction] = try [
            "protocol://app/control/terminate/?foo=bar",
            "protocol://activate?key=val",
            "protocol://plugin/PLUGIN_ID/enable/true",
        ]
        .map { try XCTUnwrap(URLComponents(string: $0)) }
        .map { try parser.parseAny($0) }

        let expectedResults = [
            AnyStringAction(mode: .moduleSubjectVerb(.init("app"), "control", "terminate"), payload: ["foo" : "bar"]),
            AnyStringAction(mode: .module(.init("activate")), payload: ["key" : "val"]),
            AnyStringAction(mode: .moduleSubjectVerbObject(.init("plugin"), "PLUGIN_ID", "enable", "true"), payload: nil),
        ]
        XCTAssertEqual(actions, expectedResults)
    }
}
