import Foundation

import XCTest

@testable import PersistedValue
import PersistedValueTestingUtilities

final class MockPersistedStorageTests: XCTestCase {

    func testValue() {
        let storage = MockPersistedStorage()

        XCTAssertEqual(storage.values.isEmpty, true)
        XCTAssertEqual(storage.gets.isEmpty, true)
        XCTAssertEqual(storage.sets.isEmpty, true)
        XCTAssertEqual(storage.inputs.isEmpty, true)

        let value = storage.persistedValue(forKey: "key")
        XCTAssertEqual(storage.values.isEmpty, true)
        XCTAssertEqual(storage.gets.isEmpty, true)
        XCTAssertEqual(storage.sets.isEmpty, true)
        XCTAssertEqual(storage.inputs, ["key"])

        let data = "1".data(using: .utf8)!
        value.wrappedValue = data
        XCTAssertEqual(storage.values, ["key": data])
        XCTAssertEqual(storage.gets.isEmpty, true)
        XCTAssertEqual(storage.sets, ["key": 1])
        XCTAssertEqual(storage.inputs, ["key"])

        let data2 = "2".data(using: .utf8)!
        storage.values["key"] = data2
        XCTAssertEqual(value.wrappedValue, data2)
        XCTAssertEqual(storage.values, ["key": data2])
        XCTAssertEqual(storage.gets, ["key": 1])
        XCTAssertEqual(storage.sets, ["key": 1])
        XCTAssertEqual(storage.inputs, ["key"])
    }
}
