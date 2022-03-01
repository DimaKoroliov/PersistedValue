
public extension PersistedValue {

    func `default`<Wrapped>(_ value: Wrapped) -> PersistedValues.Map<Self, Wrapped> where Value == Wrapped? {
        self.map(
            transform: { $0 ?? value },
            untransform: { $0 }
        )
    }
}
