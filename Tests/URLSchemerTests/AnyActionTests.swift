import URLSchemer
import XCTest

final class AnyActionTests: XCTestCase {
    func testEraseToAnyAction() {
        let action = ActionStub(
            module: Module("module"),
            subject: "subject",
            verb: "verb",
            object: "object",
            payload: ["a":"1"]
        )

        let expected = AnyAction(
            module: Module("module"),
            subject: "subject",
            verb: "verb",
            object: "object",
            payload: ["a":"1"]
        )
        XCTAssertEqual(action.eraseToAnyAction(), expected)
    }

    func testAnyActionEraseToAnyAction() {
        let anyAction = AnyAction(
            module: Module("any module"),
            subject: 55,
            verb: "add",
            object: 23.45,
            payload: ["a":"b"]
        )

        XCTAssertEqual(anyAction.eraseToAnyAction(), anyAction)
    }
}
