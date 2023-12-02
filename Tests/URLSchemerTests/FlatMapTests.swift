import URLSchemer
import XCTest

final class FlatMapTests: XCTestCase {
    struct SubjectCharacterParser: ActionParser {
        typealias Input = ActionStub
        typealias Output = ActionStub
        typealias Element = Input.Subject.Element

        let replace: (Element) -> Element

        init(replace: @escaping (Element) -> Element) {
            self.replace = replace
        }

        func parse(_ input: Input) -> ActionStub {
            .init(
                module: input.module,
                subject: String(input.subject.map(replace)),
                verb: input.verb,
                object: input.object
            )
        }
    }

    struct PassthroughParser<Input: Action>: ActionParser {
        func parse(_ input: Input) throws -> some Action {
            input
        }
    }

    func testSuccess() {
        let result = Just(ActionStub(subject: "apple"))
            .flatMap {
                SubjectCharacterParser(replace: { $0 == "p" ? "x" : $0 })
            }
            .parse(())
        XCTAssertEqual(result.subject, "axxle")
    }

    func testFailure_InUpstream_RethrowsError() {
        XCTAssertThrowsError(
            try Fail<Void, ActionStub>(error: TestError("upstream"))
                .flatMap {
                    Fail<ActionStub, ActionStub>(error: TestError("downstream"))
                }
                .parse(())
        ) { error in
            XCTAssertEqual("\(error)", "upstream")
        }
    }

    func testFailure_InDownstream_RethrowsError() {
        XCTAssertThrowsError(
            try Just(ActionStub())
                .flatMap {
                    Fail<ActionStub, ActionStub>(error: TestError("custom error"))
                }
                .parse(())
        ) { error in
            XCTAssertEqual("\(error)", "custom error")
        }
    }
}
