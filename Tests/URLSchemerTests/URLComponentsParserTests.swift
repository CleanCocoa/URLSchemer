import URLSchemer
import XCTest

final class URLComponentsParserTests: XCTestCase {
    func testParse() throws {
        let components = try XCTUnwrap(URLComponents(string: "example://module/subject/verb"))
        XCTAssertEqual(try URLComponentsParser().parse(components), StringAction(module: "module", subject: "subject", verb: "verb"))
    }

    func testParseWithFlatMap() throws {
        let components = try XCTUnwrap(URLComponents(string: "myapp://amazing/action/execute/withpower?intensity=9000"))
        let result = try components.parse { Passthrough<StringAction>() }
        XCTAssertEqual(result, StringAction(module: "amazing", subject: "action", verb: "execute", object: "withpower", payload: ["intensity":"9000"]))
    }
}
