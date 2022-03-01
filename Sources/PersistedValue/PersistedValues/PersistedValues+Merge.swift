
public extension PersistedValue {

    func merge<U>(
        with persistedValue: U,
        merge: @escaping (Value, Value) -> Value
    ) -> PersistedValues.Merge<Self, U> where U: PersistedValue, U.Value == Value {
        .init(self, persistedValue, merge: merge)
    }

    func merge<U>(
        with persistedValue: U,
        merge: @escaping (Value, Value) -> Value = { $1 }
    ) -> PersistedValues.Merge<Self, AnyPersistedValue<Value>> where U: PersistedValue, U.Value == Value? {
        .init(self, persistedValue.default(self.wrappedValue).eraseToAnyPersistedValue()) {
            merge($0, $1)
        }
    }
}

extension PersistedValues {

    public struct Merge<Upstream1, Upstream2>: PersistedValue
    where
        Upstream1: PersistedValue,
        Upstream2: PersistedValue,
        Upstream1.Value == Upstream2.Value
    {

        public typealias Value = Upstream1.Value

        public var wrappedValue: Value {
            get {
                merge(self.upstream1.wrappedValue, self.upstream2.wrappedValue)
            }

            nonmutating set {
                self.upstream1.wrappedValue = newValue
                self.upstream2.wrappedValue = newValue
            }
        }

        private let merge: (Value, Value) -> Value
        private let upstream1: Upstream1
        private let upstream2: Upstream2

        init(_ upstream1: Upstream1, _ upstream2: Upstream2, merge: @escaping (Value, Value) -> Value) {
            self.upstream1 = upstream1
            self.upstream2 = upstream2
            self.merge = merge
        }
    }
}

