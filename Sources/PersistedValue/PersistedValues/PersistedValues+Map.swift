
public extension PersistedValue {

    func map<U>(
        transform: @escaping  (Value) -> U,
        untransform: @escaping  (U) -> Value
    ) -> PersistedValues.Map<Self, U> {
        .init(upstream: self, transform: transform, untransform: untransform)
    }
}

extension PersistedValues {

    public struct Map<Upstream, Value>: PersistedValue where Upstream: PersistedValue {

        public var wrappedValue: Value {
            get {
                self.transform(self.upstream.wrappedValue)
            }

            nonmutating set {
                self.upstream.wrappedValue = self.untransform(newValue)
            }
        }

        private let upstream: Upstream
        private let transform: (Upstream.Value) -> Value
        private let untransform: (Value) -> Upstream.Value

        init(
            upstream: Upstream,
            transform: @escaping (Upstream.Value) -> Value,
            untransform: @escaping (Value) -> Upstream.Value
        ) {
            self.upstream = upstream
            self.transform = transform
            self.untransform = untransform
        }
    }
}
