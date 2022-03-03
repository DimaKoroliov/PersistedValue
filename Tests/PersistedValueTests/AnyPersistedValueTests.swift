import Foundation

import XCTest

@testable import PersistedValue
import PersistedValueTestingUtilities

final class AnyPersistedValueTests: XCTestCase {

    private let key = "key"
    private var storage: MockPersistedStorage!

    override func setUp() {
        self.storage = .init()
    }

    override func tearDown() {
        self.storage = nil
    }

    func testInit() {
        var gets = 0
        var sets = 0
        let sut = AnyPersistedValue<Void>(get: { gets += 1 }, set: { sets += 1 })

        _ = sut.wrappedValue
        XCTAssertEqual(gets, 1)
        XCTAssertEqual(sets, 0)

        sut.wrappedValue = ()
        XCTAssertEqual(gets, 1)
        XCTAssertEqual(sets, 1)
    }

    func testInitWithPersistedValue() {
        let value = self.storage.persistedValue(forKey: "key")
        let sut = AnyPersistedValue(value)

        _ = sut.wrappedValue
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], nil)


        sut.wrappedValue = Data()
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], 1)
    }

    func testTypeEraser() {
        let value = self.storage.persistedValue(forKey: "key")
        let sut = value.eraseToAnyPersistedValue()

        _ = sut.wrappedValue
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], nil)


        sut.wrappedValue = Data()
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], 1)
    }
}
