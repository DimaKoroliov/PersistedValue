import Foundation

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
}
