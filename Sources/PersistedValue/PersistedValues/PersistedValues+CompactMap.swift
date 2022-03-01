
public extension PersistedValue {

    func compactMap<U>(
        transform: @escaping  (Value) -> U,
        untransform: @escaping  (U) -> Value?
    ) -> PersistedValues.CompactMap<Self, U> {
        .init(upstream: self, transform: transform, untransform: untransform)
    }
}

extension PersistedValues {

    public struct CompactMap<Upstream, Value>: PersistedValue where Upstream: PersistedValue {

        public var wrappedValue: Value {
            get {
                self.transform(self.upstream.wrappedValue)
            }

            nonmutating set {
                self.untransform(newValue).map { self.upstream.wrappedValue = $0 }
            }
        }

        private let upstream: Upstream
        private let transform: (Upstream.Value) -> Value
        private let untransform: (Value) -> Upstream.Value?

        init(
            upstream: Upstream,
            transform: @escaping (Upstream.Value) -> Value,
            untransform: @escaping (Value) -> Upstream.Value?
        ) {
            self.upstream = upstream
            self.transform = transform
            self.untransform = untransform
        }
    }
}
