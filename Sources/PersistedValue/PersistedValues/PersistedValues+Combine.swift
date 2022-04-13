import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension PersistedValue {

    func subject<P>(didChage: P) -> PersistedValues.Subject<Value> where P: Publisher, P.Output == Void, P.Failure == Never {
        .init(upstream: self, didChage: didChage)
    }

    func subject() -> PersistedValues.Subject<Value> {
        .init(upstream: self, didChage: Empty())
    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PersistedValues {

    public final class Subject<Value>: PersistedValue, Combine.Subject {

        public typealias Output = Value
        public typealias Failure = Never

        public var wrappedValue: Value {
            get {
                self.upstream.wrappedValue
            }

            set {
                self.upstream.wrappedValue = newValue
                self.didSet.send(newValue)
            }
        }

        private let upstream: AnyPersistedValue<Value>
        private let subject: PassthroughSubject<Value, Never>
        private let didSet = PassthroughSubject<Value, Never>()
        private var cancellable: Cancellable?

        init<Upstream, P>(
          upstream: Upstream,
          didChage: P
        ) where P: Publisher, P.Output == Void, P.Failure == Never, Upstream: PersistedValue, Upstream.Value == Value {
          self.upstream = upstream.eraseToAnyPersistedValue()

            if didChage is Empty<Void, Never> {
                self.subject = self.didSet
            } else {
                self.subject = .init()
                self.cancellable = didChage
                    .map { upstream.wrappedValue }
                    .subscribe(self.subject)
            }
        }

        public func send(_ value: Value) {
            self.wrappedValue = value
        }

        public func send(completion: Subscribers.Completion<Never>) {
            Swift.print("DO NOT USE completion for PersistedValues.Subject")
        }

        public func send(subscription: Subscription) {
            Swift.print("DO NOT USE subscription for PersistedValues.Subject")
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Value == S.Input {
            self.subject.prepend(self.wrappedValue).receive(subscriber: subscriber)
        }
    }
}
