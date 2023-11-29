import XCTest
@testable import URLSchemer

extension Action where Self == StringAction {
    init(
        module moduleName: String,
        subject: String,
        verb: String,
        object: String? = nil,
        payload: Payload? = nil
    ) {
        self.init(
            module: .init(moduleName),
            subject: subject,
            verb: verb,
            object: object,
            payload: payload
        )
    }
}

final class StringActionTests: XCTestCase {
    func action(urlComponents string: String) throws -> StringAction {
        let urlComponents = try XCTUnwrap(URLComponents(string: string))
        return try Parsers.URLComponentsParser().parse(urlComponents)
    }

    func testFromURLComponents_WithoutPayload() throws {
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/path4"),
                       StringAction(module: "host", subject: "path1", verb: "path2", object: "path3"))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/"), // Nota bene: trailing slash
                       StringAction(module: "host", subject: "path1", verb: "path2", object: "path3"))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2"),
                       StringAction(module: "host", subject: "path1", verb: "path2"))
        XCTAssertThrowsError(try action(urlComponents: "protocol://host/path1"))
        XCTAssertThrowsError(try action(urlComponents: "protocol://host"))
        XCTAssertThrowsError(try action(urlComponents: "protocol://"))
    }

    func testFromURLComponents_WithPayload() throws {
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/path4?a=1&a=2&b&c=&d=5"),
                       StringAction(module: "host", subject: "path1", verb: "path2", object: "path3", payload: ["a":"2","b":nil,"c":"","d":"5"]))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/?foo=bar&foo=baz"), // Nota bene: trailing slash
                       StringAction(module: "host", subject: "path1", verb: "path2", object: "path3", payload: ["foo":"baz"]))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2?key=var"),
                       StringAction(module: "host", subject: "path1", verb: "path2", payload: ["key":"var"]))
        XCTAssertThrowsError(try action(urlComponents: "protocol://host/path1?irrelevant=yes"))
        XCTAssertThrowsError(try action(urlComponents: "protocol://host?irrelevant=yes"))
        XCTAssertThrowsError(try action(urlComponents: "protocol://?irrelevant=yes"))
    }
}
