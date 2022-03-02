import Foundation

public extension PersistedValue {

    func atomic() -> PersistedValues.Atomic<Self> {
        .init(upstream: self)
    }
}

extension PersistedValues {

    public struct Atomic<Upstream>: PersistedValue where Upstream: PersistedValue {

        public typealias Value = Upstream.Value

        public var wrappedValue: Value {
            get {
                return self.withValue { $0 }
            }

            nonmutating set {
                self.withValue { _ in self.upstream.wrappedValue = newValue }
            }
        }

        private let lock = NSLock.init()
        private let upstream: Upstream

        public func mutate(_ transform: (inout Upstream.Value) -> ()) {
            withValue {
                var val = $0
                transform(&val)
                self.upstream.wrappedValue = val
            }
        }

        init(upstream: Upstream) {
            self.upstream = upstream
        }

        func withValue<Result>(_ action: (Value) -> Result) -> Result {
            self.lock.lock()
            defer { self.lock.unlock() }

            return action(self.upstream.wrappedValue)
        }
    }
}
