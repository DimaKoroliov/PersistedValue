import Foundation
import Combine

public protocol PersistedStorage {
    func persistedValue(forKey key: String) -> AnyPersistedValue<Data?>

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func didChange(forKey key: String) -> AnyPublisher<Void, Never>
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension PersistedStorage {

    func didChange(forKey key: String) -> AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    func persistedSubject<V>(
        forKey key: String,
        make: (AnyPersistedValue<Data?>) -> V
    ) -> PersistedValues.Subject<V.Value> where V: PersistedValue {
        make(persistedValue(forKey: key)).subject(didChage: didChange(forKey: key))
    }

    func persistedSubject(forKey key: String) -> PersistedValues.Subject<Data?> {
        persistedValue(forKey: key).subject(didChage: didChange(forKey: key))
    }
}
