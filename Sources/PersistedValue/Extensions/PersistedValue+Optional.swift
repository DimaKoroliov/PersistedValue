
public extension PersistedValue {

    func optional() -> PersistedValues.CompactMap<Self, Value?> {
        self.compactMap(
            transform: Optional.some,
            untransform: { $0 }
        )
    }
}

public extension PersistedValue where Value: OptionalProtocol {

    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value.Wrapped, Subject>) -> AnyPersistedValue<Subject?> {
        AnyPersistedValue<Subject?>(
            get: { self.wrappedValue.value?[keyPath: keyPath] },
            set: { $0.map { self.wrappedValue.value?[keyPath: keyPath] = $0 } }
        )
    }

    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value.Wrapped, Subject?>) -> AnyPersistedValue<Subject?> {
        AnyPersistedValue<Subject?>(
            get: { self.wrappedValue.value?[keyPath: keyPath] },
            set: { self.wrappedValue.value?[keyPath: keyPath] = $0 }
        )
    }
}

public protocol OptionalProtocol {
    associatedtype Wrapped
    var value: Wrapped? { get set }
}

extension Optional: OptionalProtocol {
    public var value: Wrapped? {
        get { self }
        set { self = newValue }
    }
}
