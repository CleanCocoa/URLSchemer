import XCTest
@testable import URLSchemer

extension Action {
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

final class ActionTests: XCTestCase {
    func action(urlComponents string: String) throws -> Action? {
        let urlComponents = try XCTUnwrap(URLComponents(string: string))
        return Action(urlComponents: urlComponents)
    }

    func testFromURLComponents_WithoutPayload() throws {
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/path4"),
                       Action(module: "host", subject: "path1", verb: "path2", object: "path3"))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/"), // Nota bene: trailing slash
                       Action(module: "host", subject: "path1", verb: "path2", object: "path3"))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2"),
                       Action(module: "host", subject: "path1", verb: "path2"))
        XCTAssertNil(try action(urlComponents: "protocol://host/path1"))
        XCTAssertNil(try action(urlComponents: "protocol://host"))
        XCTAssertNil(try action(urlComponents: "protocol://"))
    }

    func testFromURLComponents_WithPayload() throws {
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/path4?a=1&a=2&b&c=&d=5"),
                       Action(module: "host", subject: "path1", verb: "path2", object: "path3", payload: ["a":"2","b":nil,"c":"","d":"5"]))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2/path3/?foo=bar&foo=baz"), // Nota bene: trailing slash
                       Action(module: "host", subject: "path1", verb: "path2", object: "path3", payload: ["foo":"baz"]))
        XCTAssertEqual(try action(urlComponents: "protocol://host/path1/path2?key=var"),
                       Action(module: "host", subject: "path1", verb: "path2", payload: ["key":"var"]))
        XCTAssertNil(try action(urlComponents: "protocol://host/path1?irrelevant=yes"))
        XCTAssertNil(try action(urlComponents: "protocol://host?irrelevant=yes"))
        XCTAssertNil(try action(urlComponents: "protocol://?irrelevant=yes"))
    }
}
