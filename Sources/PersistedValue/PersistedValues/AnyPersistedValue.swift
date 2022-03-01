import Foundation

@dynamicMemberLookup
public struct AnyPersistedValue<Value>: PersistedValue {
    private let get: () -> Value
    private let set: (Value) -> Void

    public var wrappedValue: Value {
        get { self.get() }
        nonmutating set { self.set(newValue) }
    }

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> AnyPersistedValue<Subject> {
        AnyPersistedValue<Subject>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

public extension AnyPersistedValue {

    init<T>(_ persistedValue: T) where T: PersistedValue, T.Value == Value {
        self.init(get: { persistedValue.wrappedValue }, set: { persistedValue.wrappedValue = $0 })
    }
}

extension PersistedValue {

    func eraseToAnyPersistedValue() -> AnyPersistedValue<Value> {
        AnyPersistedValue(self)
    }
}
