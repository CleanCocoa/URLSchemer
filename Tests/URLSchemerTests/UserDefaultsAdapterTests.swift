@testable import URLSchemer
import XCTest

extension UserDefaults {
    func removeAll() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
    }
}

final class UserDefaultsAdapterTests: XCTestCase {
    lazy var defaults: UserDefaults = UserDefaults(suiteName: String(describing: type(of: Self.self)))!

    override func setUpWithError() throws {
        defaults.removeAll()
        defaults.removeVolatileDomain(forName: UserDefaults.registrationDomain)
    }

    override func tearDownWithError() throws {
        defaults.removeAll()
    }
}

extension UserDefaultsAdapterTests {
    func testPrimitives() {
        typealias Primitive = _UserDefaultsValue & Equatable
        let keyValuePairs: [String: any Primitive] = [
            "Bool": true,
            "UInt": UInt.max,
            "UInt64": UInt64.max,
            "UInt32": UInt32.max,
            "UInt16": UInt16.max,
            "UInt8": UInt8.max,
            "Int": Int.min,
            "Int64": Int64.min,
            "Int32": Int32.min,
            "Int16": Int16.min,
            "Int8": Int8.min,
            "Double": Double.greatestFiniteMagnitude,
            "Float32": Float32.greatestFiniteMagnitude,
            "String": "Hello, world!",
            "Data": 0b10100101,
            "Date": Date(timeIntervalSince1970: 9876),
            "Optional<Bool>": Optional.some(true),
            "Optional<UInt>": Optional.some(UInt.max),
            "Optional<UInt64>": Optional.some(UInt64.max),
            "Optional<UInt32>": Optional.some(UInt32.max),
            "Optional<UInt16>": Optional.some(UInt16.max),
            "Optional<UInt8>": Optional.some(UInt8.max),
            "Optional<Int>": Optional.some(Int.min),
            "Optional<Int64>": Optional.some(Int64.min),
            "Optional<Int32>": Optional.some(Int32.min),
            "Optional<Int16>": Optional.some(Int16.min),
            "Optional<Int8>": Optional.some(Int8.min),
            "Optional<Double>": Optional.some(Double.greatestFiniteMagnitude),
            "Optional<Float32>": Optional.some(Float32.greatestFiniteMagnitude),
            "Optional<String>": Optional.some("Hello, optional world!"),
            "Optional<Data>": Optional.some(0b10100101),
            "Optional<Date>": Optional.some(Date(timeIntervalSince1970: 9876)),
        ]
        keyValuePairs.forEach { key, value in
            value.save(in: defaults, key: key)
        }

        // Working on the generic dictionary representation is much simpler than having to fanout to the various typed reader methods like `string(forKey:)`. Since we don't provide a general purpose user defaults reading/writing library, we don't need any of that in production code.
        let dictionaryRepresentation = defaults.dictionaryRepresentation()
        
        func assertActualValue<V>(
            forKey key: String,
            equals value: V,
            file: StaticString = #file, line: UInt = #line
        ) where V: Primitive {
            let actual = dictionaryRepresentation[key] as? V
            XCTAssertEqual(actual, value, file: file, line: line)
        }

        for (key, value) in keyValuePairs {
            assertActualValue(forKey: key, equals: value)
        }
    }

    func testURL() throws {
        let url: URL = URL(string: "https://christiantietze.de/")!
        url.save(in: defaults, key: "URL")

        let actual = try XCTUnwrap(defaults.url(forKey: "URL"))
        XCTAssertEqual(actual, url)
    }

    func testOptionalURL() throws {
        let url: URL = URL(string: "https://christiantietze.de/optional/")!
        let optionalURL = Optional.some(url)
        optionalURL.save(in: defaults, key: "Optional<URL>")

        let actual = try XCTUnwrap(defaults.url(forKey: "Optional<URL>"))
        XCTAssertEqual(actual, url)
    }

    func testUserDefaultsApplicable() throws {
        defaults.set("Peter", forKey: "name")
        defaults.set(-7, forKey: "salary")
        defaults.set(true, forKey: "health_insurance")

        let changes: [UserDefaultsApplicable] = [
            ChangeDefaults("name", changeTo: "Oliver"),
            ChangeDefaults("salary", changeTo: 100_000),
            DeleteDefaults(key: "health_insurance"),
        ]
        changes.forEach(defaults.apply(_:))

        XCTAssertEqual(defaults.string(forKey: "name"), "Oliver")
        XCTAssertEqual(defaults.integer(forKey: "salary"), 100_000)
        XCTAssertEqual(defaults.bool(forKey: "health_insurance"), false)  // bool(forKey:) defaults to false when missing
        XCTAssertNil(defaults.object(forKey: "health_insurance"), "health_insurance should've been deleted")
    }
}
