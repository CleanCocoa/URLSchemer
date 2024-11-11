import XCTest
@testable import URLSchemer

extension Action where Self == AnyStringAction {
    init(
        module moduleName: String,
        subject: String? = nil,
        verb: String? = nil,
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
    fileprivate func action(_ string: String) throws -> AnyStringAction {
        let urlComponents = try XCTUnwrap(URLComponents(string: string))
        return try URLComponentsParser().parse(urlComponents)
    }

    func testConvenienceInit() {
        XCTAssertEqual(AnyStringAction(module: "host"),
                       AnyStringAction(mode: .module(.init("host"))))

        XCTAssertEqual(AnyStringAction(module: "host", subject: nil, verb: "irrelevant", object: nil),
                       AnyStringAction(mode: .module(.init("host"))),
                       "Skipping parameters not allowed")
        XCTAssertEqual(AnyStringAction(module: "host", subject: nil, verb: nil, object: "irrelevant"),
                       AnyStringAction(mode: .module(.init("host"))),
                       "Skipping parameters not allowed")
        XCTAssertEqual(AnyStringAction(module: "host", subject: nil, verb: "irrelevant", object: "irrelevant"),
                       AnyStringAction(mode: .module(.init("host"))),
                       "Skipping parameters not allowed")
        
        XCTAssertEqual(AnyStringAction(module: "host", subject: "path1"),
                       AnyStringAction(mode: .moduleSubject(.init("host"), "path1")))
        XCTAssertEqual(AnyStringAction(module: "host", subject: "path1", verb: nil, object: "irrelevant"),
                       AnyStringAction(mode: .moduleSubject(.init("host"), "path1")),
                       "Skipping parameters not allowed")

        XCTAssertEqual(AnyStringAction(module: "host", subject: "path1", verb: "path2"),
                       AnyStringAction(mode: .moduleSubjectVerb(.init("host"), "path1", "path2")))

        XCTAssertEqual(AnyStringAction(module: "host", subject: "path1", verb: "path2", object: "path3"),
                       AnyStringAction(mode: .moduleSubjectVerbObject(.init("host"), "path1", "path2", "path3")))
    }

    func testFromURLComponents_WithoutPayload() throws {
        XCTAssertEqual(try action("protocol://host/path1/path2/path3/path4"),
                       AnyStringAction(module: "host", subject: "path1", verb: "path2", object: "path3"))
        XCTAssertEqual(try action("protocol://host/path1/path2/path3/"), // Nota bene: trailing slash
                       AnyStringAction(module: "host", subject: "path1", verb: "path2", object: "path3"))
        XCTAssertEqual(try action("protocol://host/path1/path2"),
                       AnyStringAction(module: "host", subject: "path1", verb: "path2"))
        XCTAssertEqual(try action("protocol://host/path1"),
                       AnyStringAction(module: "host", subject: "path1"))
        XCTAssertEqual(try action("protocol://host"),
                       AnyStringAction(module: "host"))
        XCTAssertThrowsError(try action("protocol://"))
    }

    func testFromURLComponents_WithPayload() throws {
        XCTAssertEqual(try action("protocol://host/path1/path2/path3/path4?a=1&a=2&b&c=&d=5"),
                       AnyStringAction(module: "host", subject: "path1", verb: "path2", object: "path3", payload: ["a":"2","b":nil,"c":"","d":"5"]))
        XCTAssertEqual(try action("protocol://host/path1/path2/path3/?foo=bar&foo=baz"), // Nota bene: trailing slash
                       AnyStringAction(module: "host", subject: "path1", verb: "path2", object: "path3", payload: ["foo":"baz"]))
        XCTAssertEqual(try action("protocol://host/path1/path2?key=var"),
                       AnyStringAction(module: "host", subject: "path1", verb: "path2", payload: ["key":"var"]))
        XCTAssertEqual(try action("protocol://host/path1?key=var"),
                       AnyStringAction(module: "host", subject: "path1", payload: ["key":"var"]))
        XCTAssertEqual(try action("protocol://host?key=var"),
                       AnyStringAction(module: "host", payload: ["key":"var"]))
        XCTAssertThrowsError(try action("protocol://?irrelevant=yes"))
    }

    func testLowercased() {
        XCTAssertEqual(
            AnyStringAction(module: "MODULE", subject: "SUBJECT", verb: "VERB", object: "OBJECT", payload: ["KEY":"VALUE"]).lowercased(),
            AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "OBJECT", payload: ["key":"value"])
        )

        XCTAssertEqual(
            AnyStringAction(module: "MODULE", subject: "SUBJECT", verb: "VERB", object: "OBJECT", payload: ["KEY":"VALUE"]).lowercased(includingObject: true),
            AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "object", payload: ["key":"value"])
        )

        XCTAssertEqual(
            AnyStringAction(module: "MODULE", subject: "SUBJECT", verb: "VERB", object: "OBJECT", payload: nil).lowercased(includingObject: true),
            AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "object", payload: nil)
        )

        XCTAssertEqual(
            AnyStringAction(module: "MODULE", subject: "SUBJECT", verb: "VERB", object: "OBJECT", payload: nil).lowercased(),
            AnyStringAction(module: "module", subject: "subject", verb: "verb", object: "OBJECT", payload: nil)
        )

        XCTAssertEqual(
            AnyStringAction(module: "MODULE", subject: "SUBJECT", verb: "VERB", object: nil, payload: nil).lowercased(),
            AnyStringAction(module: "module", subject: "subject", verb: "verb", object: nil, payload: nil)
        )
    }
}
