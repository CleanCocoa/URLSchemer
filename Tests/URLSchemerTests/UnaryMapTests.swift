import URLSchemer
import XCTest

final class BimapTests: XCTestCase {
    func testSuccess() {
        let action = GenericAction(
            module: "module",
            subject: "subject",
            verb: "verb"
        )
        
        let mapped = action.bimap(
            transformSubject: \.count,
            transformVerb: { $0.sorted() }
        )

        XCTAssertEqual(mapped.subject, 7)
        XCTAssertEqual(mapped.verb, ["b","e","r","v"])
    }
}
