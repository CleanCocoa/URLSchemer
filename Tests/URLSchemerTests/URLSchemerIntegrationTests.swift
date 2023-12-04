@testable import URLSchemer
import XCTest

public enum URLSchemerError: Error {
    case urlParsingFailed(URLComponents, wrapped: Error)
    case conversionFailed(StringAction)
    case unhandledAction(any Action)
}

final class URLSchemerIntegrationTests: XCTestCase {
    lazy var defaults: UserDefaults = UserDefaults(suiteName: String(describing: type(of: URLSchemerIntegrationTests.self)))!

    override func setUpWithError() throws {
        defaults.removeAll()
        defaults.removeVolatileDomain(forName: UserDefaults.registrationDomain)
    }

    override func tearDownWithError() throws {
        defaults.removeAll()
    }
}

extension URLSchemerIntegrationTests {
    func execute(
        _ string: String,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let urlComponents = try XCTUnwrap(URLComponents(string: string), file: file, line: line)
        try execute(urlComponents: urlComponents)
    }

    func execute(urlComponents: URLComponents) throws {
        let stringAction: StringAction
        do {
            stringAction = try URLComponentsParser().parse(urlComponents)
        } catch {
            throw URLSchemerError.urlParsingFailed(urlComponents, wrapped: error)
        }

        let parsers: [AnyParser<StringAction>] = [
            DeleteDefaultsParser().eraseToAnyParser(),
            AppControlParser().eraseToAnyParser(),
            ChangeDefaultsParser<Int>().eraseToAnyParser(),
            ChangeDefaultsParser<Bool>().eraseToAnyParser(),
            ChangeDefaultsParser<String>().eraseToAnyParser(),
        ]

        var action: (any Action)?
        findParser: for parser in parsers {
            do {
                action = try parser.parse(stringAction)
                break findParser
            } catch ActionParsingError.failed {
                continue
            } catch {
                throw error
            }
        }
        guard let action else {
            throw URLSchemerError.conversionFailed(stringAction)
        }

        let executors: [any ActionExecutor] = [
            DeleteDefaultsExecutor(defaults: defaults),
            ChangeDefaultsExecutor<Int>(defaults: defaults),
            ChangeDefaultsExecutor<Bool>(defaults: defaults),
            ChangeDefaultsExecutor<String>(defaults: defaults),
        ]
        XCTAssertFalse(executors.contains { type(of: $0) == AppControlAction.self },
                       "To demonstrate unhandled actions, this should not be handled")

        for executor in executors {
            do {
                try executor.execute(action)
                return
            } catch ActionExecutionError.executorMismatch {
                continue
            } catch {
                throw error
            }
        }

        throw URLSchemerError.unhandledAction(action)
    }

    func testExecuting_UnknownActionTemplate_Throws() throws {
        XCTAssertThrowsError(
            try execute(urlComponents: URLComponents(string: "app://not/found/at/all")!)
        ) { error in
            switch error {
            case URLSchemerError.conversionFailed(let stringAction):
                XCTAssertEqual(stringAction, StringAction(module: "not", subject: "found", verb: "at", object: "all"))
            default:
                XCTFail("Expected URLSchemerError.conversionFailed but got \(type(of: error))")
            }
        }
    }

    func testExecuting_UnhandledAction_Throws() throws {
        XCTAssertThrowsError(
            try execute(urlComponents: URLComponents(string: "example://app/control/terminate")!)
        ) { error in
            switch error {
            case URLSchemerError.unhandledAction(let action):
                XCTAssert(type(of: action) == AppControlAction.self)
            default:
                XCTFail("Expected URLSchemerError.unhandledAction but got \(type(of: error))")
            }
        }
    }

    func testExecuting_PreferenceActions() throws {
        try execute(urlComponents: URLComponents(string: "app://preference/name/set/Peter")!)
        try execute(urlComponents: URLComponents(string: "app://preference/age/set/123")!)
        try execute(urlComponents: URLComponents(string: "app://preference/active/set/true")!)

        XCTAssertEqual(defaults.string(forKey: "name"), "Peter")
        XCTAssertEqual(defaults.integer(forKey: "age"), 123)
        XCTAssertEqual(defaults.bool(forKey: "active"), true)

        try execute(urlComponents: URLComponents(string: "app://preference/age/delete/--it-is-irrelevant/what/comes/after")!)
        XCTAssertEqual(defaults.integer(forKey: "age"), 0)
        XCTAssertNil(defaults.object(forKey: "age"))
    }
}
