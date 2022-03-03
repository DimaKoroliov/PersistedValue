import Foundation
import Combine

import XCTest

@testable import PersistedValue
import PersistedValueTestingUtilities

final class PersistedStorageTests: XCTestCase {

    private let key = "key"

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testDidChangeDefault() {
        let storage = Storage()
        var valuesCount = 0
        var completionsCount = 0
        _ = storage.didChange(forKey: key)
            .sink(receiveCompletion: { _ in completionsCount += 1 }, receiveValue: { valuesCount += 1 })

        XCTAssertEqual(valuesCount, 0)
        XCTAssertEqual(completionsCount, 1)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testPersistedSubjectData() {
        let storage = MockPersistedStorage()
        let value = storage.persistedSubject(forKey: key)

        var values: [Data?] = []
        let cancellable = value.sink { values.append($0) }

        XCTAssertEqual(values, [nil])

        let data = "123".data(using: .utf8) ?? Data()
        value.wrappedValue = data
        XCTAssertEqual(values, [nil])

        storage.didChangeSubject.send(key)
        XCTAssertEqual(values, [nil, data])
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testPersistedSubject() {
        let storage = MockPersistedStorage()
        let value = storage.persistedSubject(forKey: key) { $0.string().default("") }

        var values: [String] = []
        let cancellable = value.sink { values.append($0) }

        XCTAssertEqual(values, [""])

        let str = "123"
        value.wrappedValue = str
        XCTAssertEqual(values, [""])

        storage.didChangeSubject.send(key)
        XCTAssertEqual(values, ["", str])
    }
}

private final class Storage: PersistedStorage {

    func persistedValue(forKey key: String) -> AnyPersistedValue<Data?> {
        MockPersistedValue(nil).eraseToAnyPersistedValue()
    }
}
