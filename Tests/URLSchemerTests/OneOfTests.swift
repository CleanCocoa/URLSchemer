import URLSchemer
import XCTest

final class OneOfTests: XCTestCase {
    struct ParsedNumber: Action, Equatable {
        let module: Module = .init("tests")
        let subject = "test"
        let verb = "int"
        var object: Int
        let payload: Payload? = nil
    }

    struct OddPositiveNumberParser: ActionParser {
        typealias Input = Int
        typealias Output = ParsedNumber

        func parse(_ input: Int) throws -> ParsedNumber {
            guard input > 0,
                  (input % 2) == 1
            else {
                throw ActionParsingError.failed
            }
            return ParsedNumber(object: input)
        }
    }

    struct EvenPositiveNumberParser: ActionParser {
        typealias Input = Int
        typealias Output = ParsedNumber

        func parse(_ input: Int) throws -> ParsedNumber {
            guard input > 0,
                  (input % 2) == 0
            else {
                throw ActionParsingError.failed
            }
            return ParsedNumber(object: input)
        }
    }

    func testOneOf_OneExpression_Success() throws {
        let result = try OneOf {
            OddPositiveNumberParser()
        }.parse(1)

        XCTAssertEqual(result, ParsedNumber(object: 1))
    }

    func testOneOf_OneExpression_FailsParsing() {
        XCTAssertThrowsError(
            try OneOf {
                OddPositiveNumberParser()
            }.parse(2)
        ) { error in
            switch error {
            case ActionParsingError.failed:
                break // Happy path
            default:
                XCTFail("Expected ActionParsingError.failed but got \(type(of: error))")
            }
        }
    }

    func testOneOf_OneExpression_FailsForRealError() {
        XCTAssertThrowsError(
            try OneOf {
                Fail<Int, ActionStub>(error: TestError("real failure"))
            }.parse(2)
        ) { error in
            switch error {
            case ActionParsingError.wrapping(let wrapped):
                XCTAssert(type(of: wrapped) == TestError.self)
                XCTAssertEqual("\(wrapped)", "real failure")
            default:
                XCTFail("Expected .wrapping error but got \(type(of: error))")
            }
        }
    }

    func testOneOf_MultipleExpressions_FirstSucceeds() throws {
        let result = try OneOf {
            OddPositiveNumberParser()
            EvenPositiveNumberParser()
        }.parse(9)

        XCTAssertEqual(result, ParsedNumber(object: 9))
    }

    func testOneOf_MultipleExpressions_SecondSucceeds() throws {
        let result = try OneOf {
            OddPositiveNumberParser()
            EvenPositiveNumberParser()
        }.parse(20)

        XCTAssertEqual(result, ParsedNumber(object: 20))
    }

    func testOneOf_MultipleExpressions_AllFail() {
        XCTAssertThrowsError(
            try OneOf {
                OddPositiveNumberParser()
                EvenPositiveNumberParser()
            }.parse(-99)
        ) { error in
            switch error {
            case ActionParsingError.failed:
                break // Happy path
            default:
                XCTFail("Expected ActionParsingError.failed but got \(type(of: error))")
            }
        }
    }
}
