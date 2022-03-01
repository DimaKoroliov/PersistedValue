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
//                queue.sync { self.upstream.wrappedValue }
            }

//            _modify {
//              _makeMutableAndUnique() // makes the array native, too
//              _checkSubscript_mutating(index)
//              let address = _buffer.mutableFirstElementAddress + index
//              yield &address.pointee
//              _endMutation();
//            }

            nonmutating set {
                self.withValue { _ in self.upstream.wrappedValue = newValue }
//                queue.sync { self.upstream.wrappedValue = newValue }
            }
        }

        private let queue = DispatchQueue(label: "com.dkoroliov.atomic")
        private let lock = NSLock.init()
        private let upstream: Upstream

        public func mutate(_ transform: (inout Upstream.Value) -> ()) {
//            queue.sync {
//                transform(&self.upstream.wrappedValue)
//            }
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
//            return try queue.sync {
//                try action(self.upstream.wrappedValue)
//            }
        }
    }
}
