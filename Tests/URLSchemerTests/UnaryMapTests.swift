import URLSchemer
import XCTest

final class UnaryMapTests: XCTestCase {
    func testFoo() {
        let action = GenericAction(
            module: "module",
            subject: "subject",
            verb: "verb"
        )
        
        let mapped = action.map(
            transformSubject: \.count,
            transformVerb: { $0.sorted() }
        )

        XCTAssertEqual(mapped.subject, 7)
        XCTAssertEqual(mapped.verb, ["b","e","r","v"])
    }
}
