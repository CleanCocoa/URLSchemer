import URLSchemer
import XCTest

final class AnySubjectVerbActionTests: XCTestCase {
    func testEraseToAnySubjectVerbAction() {
        struct ConstBananaAction: SubjectVerbAction {
            let module: Module = .init("banana")
            let subject = "banana"
            let verb = "eat"
            let object = 1337
            let payload: Payload? = nil
        }

        let action = ActionStub(
            module: .init("module"),
            subject: "subject",
            verb: "verb",
            payload: ["a":"1"]
        ).map { _ in ConstBananaAction() }

        let expected = AnySubjectVerbAction(
            module: .init("banana"),
            subject: "banana",
            verb: "eat",
            payload: nil
        )
        XCTAssertEqual(action.apply().eraseToAnySubjectVerbAction(), expected)
    }

    func testAnySubjectVerbActionEraseToAnySubjectVerbAction() {
        let anyAction = AnySubjectVerbAction(
            module: .init("any module"),
            subject: "subject",
            verb: "verb",
            payload: ["a":"b"]
        )

        XCTAssertEqual(anyAction.eraseToAnySubjectVerbAction(), anyAction)
    }
}
