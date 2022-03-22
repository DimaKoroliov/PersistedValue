import Foundation
import Combine

import XCTest

@testable import PersistedValue

final class StoragesTests: XCTestCase {

    private let key = "key"
    private let key2 = "key2"
    private var cancellable: Cancellable?

    override func tearDown() {
        self.cancellable = nil
    }

    func testKeychain() {
        self.testStorage(KeychainStorage())
    }

    func testCache() {
        self.testStorage(CachePersistedStorage())
    }

    func testUserDefaults() {
        self.testStorage(UserDefaults())
    }

    private func testStorage(_ storage: PersistedStorage) {
        let value = UUID().uuidString
        var changes = 0
        self.cancellable = storage.didChange(forKey: self.key).sink { changes += 1 }
        let persisted = storage.persistedValue(forKey: self.key).string()

        XCTAssertEqual(changes, 0)

        persisted.wrappedValue = value
        XCTAssertEqual(persisted.wrappedValue, value)
        XCTAssertEqual(changes, 1)

        let value2 = UUID().uuidString
        let persisted2 = storage.persistedValue(forKey: self.key2).string()

        persisted2.wrappedValue = value2
        XCTAssertEqual(persisted2.wrappedValue, value2)
        XCTAssertEqual(persisted.wrappedValue, value)
        XCTAssertEqual(changes, 1)

        let value3 = UUID().uuidString
        let persisted3 = storage.persistedValue(forKey: self.key).string()

        persisted3.wrappedValue = value3
        XCTAssertEqual(persisted2.wrappedValue, value2)
        XCTAssertEqual(persisted.wrappedValue, value3)
        XCTAssertEqual(persisted3.wrappedValue, value3)
        XCTAssertEqual(changes, 2)

        persisted.wrappedValue = nil
        XCTAssertEqual(persisted2.wrappedValue, value2)
        XCTAssertEqual(persisted.wrappedValue, nil)
        XCTAssertEqual(persisted3.wrappedValue, nil)
        XCTAssertEqual(changes, 3)
    }
}
