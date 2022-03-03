import Foundation

@dynamicMemberLookup
public protocol PersistedValue {
    associatedtype Value

    var wrappedValue: Value { get nonmutating set }
    func mutate(_ transform: (inout Value) -> ())
}

public enum PersistedValues {}

public extension PersistedValue {

    func mutate(_ transform: (inout Value) -> ()) {
        transform(&wrappedValue)
    }

    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> AnyPersistedValue<Subject> {
        .init(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}
