import URLSchemer
import XCTest

final class UserDefaultsActionSinkTests: XCTestCase {
    lazy var defaults: UserDefaults = UserDefaults(suiteName: String(describing: type(of: Self.self)))!

    override func setUpWithError() throws {
        defaults.removeAll()
        defaults.removeVolatileDomain(forName: UserDefaults.registrationDomain)
    }

    override func tearDownWithError() throws {
        defaults.removeAll()
    }
}

extension UserDefaultsActionSinkTests {
    func testAcceptsDeleteDefaults() {
        defaults.set("Peter", forKey: "name")

        DeleteDefaults(key: "name")
            .do(UserDefaultsActionSink<DeleteDefaults>(defaults: defaults))

        XCTAssertNil(defaults.string(forKey: "name"))
    }

    func testAcceptsChangeDefaults() {
        XCTAssertEqual(defaults.integer(forKey: "age"), 0)
        XCTAssertNil(defaults.object(forKey: "age"))

        ChangeDefaults("age", changeTo: 66)
            .do(UserDefaultsActionSink<ChangeDefaults<Int>>(defaults: defaults))

        XCTAssertNotNil(defaults.object(forKey: "age"))
        XCTAssertEqual(defaults.integer(forKey: "age"), 66)
    }
}
