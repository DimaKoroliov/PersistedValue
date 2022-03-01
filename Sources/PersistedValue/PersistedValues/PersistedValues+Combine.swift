import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension PersistedValue {

    func subject<P>(didChage: P) -> PersistedValues.Subject<Self> where P: Publisher, P.Output == Void {
        .init(upstream: self, didChage: didChage)
    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PersistedValues {

    public final class Subject<Upstream>: PersistedValue, Combine.Subject where Upstream: PersistedValue {

        public typealias Value = Upstream.Value
        public typealias Output = Value
        public typealias Failure = Never

        public var wrappedValue: Value {
            get {
                self.upstream.wrappedValue
            }

            set {
                self.upstream.wrappedValue = newValue
//                self.subject.send(newValue)
            }
        }

        private let upstream: Upstream
        private let subject: PassthroughSubject<Value, Never> = .init()
        private var cancellable: Cancellable?

        init<P>(upstream: Upstream, didChage: P) where P: Publisher, P.Output == Void {
            self.upstream = upstream

            cancellable = didChage
                .catch { _ in Empty() }
                .map { upstream.wrappedValue }
                .subscribe(self.subject)
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
