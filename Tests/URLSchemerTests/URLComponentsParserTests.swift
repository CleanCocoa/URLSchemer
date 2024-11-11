import URLSchemer
import XCTest

final class URLComponentsParserTests: XCTestCase {
    func testParse() throws {
        let components = try XCTUnwrap(URLComponents(string: "example://module/subject/verb"))
        XCTAssertEqual(try URLComponentsParser().parse(components), AnyStringAction(module: "module", subject: "subject", verb: "verb"))
    }

    func testParseWithPassthrough() throws {
        let components = try XCTUnwrap(URLComponents(string: "myapp://amazing/action/execute/withpower?intensity=9000"))
        let result = try components.parse { Passthrough<AnyStringAction>() }
        XCTAssertEqual(result, AnyStringAction(module: "amazing", subject: "action", verb: "execute", object: "withpower", payload: ["intensity":"9000"]))
    }
}
