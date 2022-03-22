import Foundation

import XCTest

@testable import PersistedValue
import PersistedValueTestingUtilities

final class MockPersistedValueTests: XCTestCase {

    func testValue() {
        let value = MockPersistedValue<String?>(nil)

        XCTAssertEqual(value.outputsCount, 0)
        XCTAssertEqual(value.wrappedValue, nil)
        XCTAssertEqual(value.outputsCount, 1)

        value.wrappedValue = "1"
        XCTAssertEqual(value.inputs, ["1"])
        XCTAssertEqual(value.wrappedValue, "1")
        XCTAssertEqual(value.outputsCount, 2)

        value.wrappedValue = "2"
        XCTAssertEqual(value.inputs, ["1", "2"])
    }
}
