import Foundation
import Combine

extension UserDefaults: PersistedStorage {

    public func persistedValue(forKey key: String) -> AnyPersistedValue<Data?> {
        AnyPersistedValue(
            get: { self.data(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func didChange(forKey key: String) -> AnyPublisher<Void, Never> {
        KeyValueObserver(self, forKey: key).map { _ in }.eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class KeyValueObserver: NSObject, Publisher {

    typealias Output = Any
    typealias Failure = Never

    let keyPath: String
    weak var object: AnyObject?
    let subject = PassthroughSubject<Output, Never>()

    init(_ object: AnyObject, forKey keyPath: String) {
        self.keyPath = keyPath
        self.object = object
        super.init()

        self.object?.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
    }

    deinit {
        self.object?.removeObserver(self, forKeyPath: self.keyPath)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == self.keyPath, let newValue = change?[.newKey] else {
            return
        }

        self.subject.send(newValue)
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        subscriber.receive(subscription: KeyValueObserverSubscription(observer: self, subscriber: subscriber))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private final class KeyValueObserverSubscription<S>: Subscription
where
    S: Subscriber,
    S.Input == Any,
    S.Failure == Never
{
    private var observer: KeyValueObserver?
    private var subscriber: S?
    private var cancellable: Cancellable?

    init(observer: KeyValueObserver, subscriber: S) {
        self.observer = observer
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        guard
            let observer = observer,
            let subscriber = subscriber,
            cancellable == nil
        else {
            return
        }

        cancellable = observer.subject.sink { _ = subscriber.receive($0) }
    }

    func cancel() {
        cancellable = nil
        observer = nil
        subscriber = nil
    }
}
