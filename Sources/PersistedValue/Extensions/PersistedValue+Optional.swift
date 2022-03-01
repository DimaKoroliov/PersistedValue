
public extension PersistedValue {

    func optional() -> PersistedValues.CompactMap<Self, Value?> {
        self.compactMap(
            transform: Optional.some,
            untransform: { $0 }
        )
    }
}
