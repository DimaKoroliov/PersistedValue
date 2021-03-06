import Foundation
import Combine

import XCTest

@testable import PersistedValue
import PersistedValueTestingUtilities

final class PersistedValueTests: XCTestCase {

    private let key = "key"
    private var storage: MockPersistedStorage!

    override func setUp() {
        self.storage = .init()
    }

    override func tearDown() {
        self.storage = nil
    }

    func testWrappedValue() {
        let persistedValue = self.storage.persistedValue(forKey: key)

        XCTAssertEqual(persistedValue.wrappedValue, nil)
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], nil)

        let data = Data()
        persistedValue.wrappedValue = data
        XCTAssertEqual(persistedValue.wrappedValue, data)
        XCTAssertEqual(self.storage.values[key], data)
        XCTAssertEqual(self.storage.gets[key], 2)
        XCTAssertEqual(self.storage.sets[key], 1)

        persistedValue.wrappedValue = nil
        XCTAssertEqual(persistedValue.wrappedValue, nil)
        XCTAssertEqual(self.storage.values[key], nil)
        XCTAssertEqual(self.storage.gets[key], 3)
        XCTAssertEqual(self.storage.sets[key], 2)
    }

    func testMutate() {
        let persistedValue = self.storage.persistedValue(forKey: key)
        let data: Data! = "1".data(using: .utf8)
        let newData: Data! = "2".data(using: .utf8)
        persistedValue.wrappedValue = data
        persistedValue.mutate { current in
            XCTAssertEqual(current, data)
            current = newData
        }

        XCTAssertEqual(persistedValue.wrappedValue, newData)
        XCTAssertEqual(self.storage.values[key], newData)
        XCTAssertEqual(self.storage.gets[key], 2)
        XCTAssertEqual(self.storage.sets[key], 2)
    }

    func testString() {
        let persistedValue = self.storage.persistedValue(forKey: key).string()
        let str = "1"
        persistedValue.wrappedValue = str

        XCTAssertEqual(persistedValue.wrappedValue, str)
        XCTAssertEqual(self.storage.values[key], str.data(using: .utf8))
    }

    func testInteger() {
        let persistedValue = self.storage.persistedValue(forKey: key)
            .integer(Int.self)

        let int = 1
        persistedValue.wrappedValue = int

        XCTAssertEqual(persistedValue.wrappedValue, int)
        XCTAssertEqual(self.storage.values[key], "\(int)".data(using: .utf8))
    }

    func testBool() {
        let persistedValue = self.storage.persistedValue(forKey: key)
            .bool()

        var bool = true
        persistedValue.wrappedValue = bool

        XCTAssertEqual(persistedValue.wrappedValue, bool)
        XCTAssertEqual(self.storage.values[key], Data([1]))

        bool = false
        persistedValue.wrappedValue = bool

        XCTAssertEqual(persistedValue.wrappedValue, bool)
        XCTAssertEqual(self.storage.values[key], Data([]))
    }

    func testDefault() {
        let initial = "1"
        let persistedValue = self.storage.persistedValue(forKey: key)
            .string()
            .default(initial)

        XCTAssertEqual(persistedValue.wrappedValue, initial)
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], nil)

        let str = "2"
        persistedValue.wrappedValue = str

        XCTAssertEqual(persistedValue.wrappedValue, str)
        XCTAssertEqual(self.storage.sets[key], 1)
    }

    func testCodable() {
        let persistedValue = self.storage.persistedValue(forKey: key)
            .codable(Model.self)

        XCTAssertEqual(persistedValue.wrappedValue, nil)
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], nil)

        let model = Model(str: "1")
        persistedValue.wrappedValue = model

        XCTAssertEqual(persistedValue.wrappedValue, model)
        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.values[key], try? JSONEncoder().encode(model))
    }

    func testOptional() {
        let initial = "1"
        let persistedValue = self.storage.persistedValue(forKey: key)
            .string()
            .default(initial)
            .optional()

        XCTAssertEqual(persistedValue.wrappedValue, initial)
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.sets[key], nil)

        let str = "2"
        persistedValue.wrappedValue = str

        XCTAssertEqual(persistedValue.wrappedValue, str)
        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.values[key], str.data(using: .utf8))

        persistedValue.wrappedValue = nil

        XCTAssertEqual(persistedValue.wrappedValue, str)
        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.values[key], str.data(using: .utf8))
    }

    func testMap() {
        let persistedValue = self.storage.persistedValue(forKey: key)
            .string()
            .map(transform: { $0?.uppercased() }, untransform: { $0?.lowercased() })

        let str = "UpDown"
        storage.values[key] = str.data(using: .utf8)

        XCTAssertEqual(persistedValue.wrappedValue, str.uppercased())
        XCTAssertEqual(self.storage.gets[key], 1)

        persistedValue.wrappedValue = str.uppercased()

        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.values[key], str.lowercased().data(using: .utf8))
    }

    func testCompactMap() {
        let persistedValue = self.storage.persistedValue(forKey: key)
            .string()
            .compactMap(transform: { $0 }, untransform: { $0 == "1" ? $0 : nil })

        let str = "1"
        persistedValue.wrappedValue = str

        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.values[key], str.data(using: .utf8))

        persistedValue.wrappedValue = "2"

        XCTAssertEqual(self.storage.sets[key], 1)
    }

    func testMerge() {
        let pv1 = self.storage.persistedValue(forKey: key)
            .string()

        let key2 = "key2"
        let pv2 = self.storage.persistedValue(forKey: key2)
            .string()

        let merge = pv1.merge(with: pv2) { $0 ?? $1 }

        XCTAssertEqual(merge.wrappedValue, nil)
        XCTAssertEqual(self.storage.gets[key], 1)
        XCTAssertEqual(self.storage.gets[key2], 1)

        let str = "1"
        pv1.wrappedValue = str
        XCTAssertEqual(merge.wrappedValue, str)
        XCTAssertEqual(self.storage.gets[key], 2)
        XCTAssertEqual(self.storage.gets[key2], 2)
        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.sets[key2], nil)

        let str2 = "2"
        merge.wrappedValue = str2
        XCTAssertEqual(pv1.wrappedValue, str2)
        XCTAssertEqual(pv2.wrappedValue, str2)
        XCTAssertEqual(self.storage.sets[key], 2)
        XCTAssertEqual(self.storage.sets[key2], 1)
        XCTAssertEqual(self.storage.values[key], str2.data(using: .utf8))
        XCTAssertEqual(self.storage.values[key2], str2.data(using: .utf8))
    }

    func testMergeWhenNonOptional() {
        let pv1 = self.storage.persistedValue(forKey: key)
            .string()
            .default("")

        let key2 = "key2"
        let pv2 = self.storage.persistedValue(forKey: key2)
            .string()

        let merge = pv1.merge(with: pv2)

        XCTAssertEqual(merge.wrappedValue, "")
        XCTAssertEqual(self.storage.gets[key], 2)
        XCTAssertEqual(self.storage.gets[key2], 1)

        let str = "1"
        pv1.wrappedValue = str
        XCTAssertEqual(merge.wrappedValue, str)
        XCTAssertEqual(self.storage.gets[key], 3)
        XCTAssertEqual(self.storage.gets[key2], 2)
        XCTAssertEqual(self.storage.sets[key], 1)
        XCTAssertEqual(self.storage.sets[key2], nil)

        let str2 = "2"
        merge.wrappedValue = str2
        XCTAssertEqual(pv1.wrappedValue, str2)
        XCTAssertEqual(pv2.wrappedValue, str2)
        XCTAssertEqual(self.storage.sets[key], 2)
        XCTAssertEqual(self.storage.sets[key2], 1)
        XCTAssertEqual(self.storage.values[key], str2.data(using: .utf8))
        XCTAssertEqual(self.storage.values[key2], str2.data(using: .utf8))
    }

    func testDynamicMemberLookup() {
        let str = self.storage.persistedValue(forKey: key)
            .codable(Model.self)
            .default(.init())
            .str

        let value = self.storage.persistedValue(forKey: key).codable(Model.self)

        str.wrappedValue = "123"
        XCTAssertEqual(value.wrappedValue?.str, "123")

        let opt = self.storage.persistedValue(forKey: key)
            .codable(Model.self)
            .opt

        opt.wrappedValue = "123"
        XCTAssertEqual(value.wrappedValue?.opt, "123")

        opt.wrappedValue = nil
        XCTAssertEqual(value.wrappedValue?.opt, nil)
    }

    func testDynamicMemberLookupWhenOptional() {
        self.storage.persistedValue(forKey: key).codable(Model.self).wrappedValue = .init()
        let str = self.storage.persistedValue(forKey: key)
            .codable(Model.self)
            .str

        let value = self.storage.persistedValue(forKey: key).codable(Model.self)

        str.wrappedValue = "123"
        XCTAssertEqual(value.wrappedValue?.str, "123")

        str.wrappedValue = nil
        XCTAssertEqual(value.wrappedValue?.str, "123")

        let opt = self.storage.persistedValue(forKey: key)
            .codable(Model.self)
            .opt

        opt.wrappedValue = "123"
        XCTAssertEqual(value.wrappedValue?.opt, "123")

        opt.wrappedValue = nil
        XCTAssertEqual(value.wrappedValue?.opt, nil)
    }

    func testPrint() {
        let stream = OutputStream()
        let sut = self.storage.persistedValue(forKey: key)
            .integer(Int.self)
            .default(0)
            .print(to: stream)

        sut.wrappedValue = 1
        XCTAssertEqual(stream.inputs, ["set value: (1)"])

        _ = sut.wrappedValue
        XCTAssertEqual(stream.inputs.dropFirst(), ["get value: (1)"])
    }

    func testPrintWithPrefix() {
        let stream = OutputStream()
        let sut = self.storage.persistedValue(forKey: key)
            .integer(Int.self)
            .default(0)
            .print("prefix", to: stream)

        sut.wrappedValue = 1
        XCTAssertEqual(stream.inputs, ["prefix: set value: (1)"])

        _ = sut.wrappedValue
        XCTAssertEqual(stream.inputs.dropFirst(), ["prefix: get value: (1)"])
    }

    func testAtomic() {
        let sut = self.storage.persistedValue(forKey: key)
            .integer(Int.self)
            .default(0)
            .atomic()

        var extectations: [XCTestExpectation] = []
        var sum = 0
        for i in 0...1000 {
            sum += i
            let exp = expectation(description: "\(i)")
            extectations.append(exp)
            DispatchQueue.global().async {
                sut.mutate { $0 += i }
                exp.fulfill()
            }
        }

        wait(for: extectations, timeout: 1)

        XCTAssertEqual(sut.wrappedValue, sum)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testSubject() {
        let sut = self.storage.persistedValue(forKey: key)
            .integer(Int.self)
            .default(0)
            .subject()

        var values: [Int] = []
        let cancellable = sut.sink { values.append($0) }

        XCTAssertEqual(values, [0])

        sut.wrappedValue = 2
        XCTAssertEqual(values, [0, 2])
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testSubjectWhenDidChange() {
        let didChage = PassthroughSubject<Void, Never>()
        let sut = self.storage.persistedValue(forKey: key)
            .integer(Int.self)
            .default(0)
            .subject(didChage: didChage)

        var values: [Int] = []
        let cancellable = sut.sink { values.append($0) }

        XCTAssertEqual(values, [0])

        sut.wrappedValue = 2
        XCTAssertEqual(values, [0])

        didChage.send()
        XCTAssertEqual(values, [0, 2])
    }
}

struct Model: Codable, Equatable {
    var str: String = ""
    var opt: String?
}

final class OutputStream: TextOutputStream {
    private(set) var inputs: [String] = []

    func write(_ string: String) {
        inputs.append(string)
    }
}
