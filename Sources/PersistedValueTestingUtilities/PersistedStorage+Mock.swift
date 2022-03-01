import Foundation
import Combine

import PersistedValue

public final class MockPersistedStorage: PersistedStorage {
    public var values: [String: Data] = [:]
    public private(set) var gets: [String: Int] = [:]
    public private(set) var sets: [String: Int] = [:]
    public private(set) var inputs: [String] = []

    private var subject: Any?

    public init() {}

    public func persistedValue(forKey key: String) -> AnyPersistedValue<Data?> {
        self.inputs.append(key)
        return AnyPersistedValue(
            get: {
                self.gets[key, default: 0] += 1
                return self.values[key]
            },
            set: {
                self.sets[key, default: 0] += 1
                self.values[key] = $0
            }
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension MockPersistedStorage {
    var didChangeSubject: PassthroughSubject<String, Never> {
        guard let subject = self.subject as? PassthroughSubject<String, Never> else {
            let subject = PassthroughSubject<String, Never>()
            self.subject = subject
            return subject
        }

        return subject
    }

    func didChange(forKey key: String) -> AnyPublisher<Void, Never> {
        didChangeSubject.filter { $0 == key }.map { _ in }.eraseToAnyPublisher()
    }
}
