import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private let didChangeSubject = PassthroughSubject<String, Never>()

public struct CachePersistedStorage: PersistedStorage {

    public final class Entity: NSObject {
        let key: NSString
        let data: NSData

        init(key: NSString, data: NSData) {
            self.key = key
            self.data = data
        }
    }

    private class Tracker: NSObject, NSCacheDelegate {

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entity = obj as? Entity else {
                return
            }

            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                didChangeSubject.send(entity.key as String)
            }
        }
    }

    private let storage: NSCache<NSString, Entity>
    private let tracker = Tracker()

    public init(storage: NSCache<NSString, Entity> = .init()) {
        self.storage = storage
        self.storage.delegate = self.tracker
    }

    public func persistedValue(forKey key: String) -> AnyPersistedValue<Data?> {
        AnyPersistedValue(
            get: { self.storage.object(forKey: key as NSString)?.data as Data? },
            set: { data in
                let nskey = key as NSString
                guard let data = data else {
                    self.storage.removeObject(forKey: nskey)
                    return
                }

                self.storage.setObject(.init(key: nskey, data: data as NSData), forKey: nskey)
                
                if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                    didChangeSubject.send(key)
                }
            }
        )
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func didChange(forKey key: String) -> AnyPublisher<Void, Never> {
        didChangeSubject.filter { $0 == key }.map { _ in }.eraseToAnyPublisher()
    }
}
