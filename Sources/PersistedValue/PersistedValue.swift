import Foundation

/// A value that can be persisted by storage (`PersistedStorage`).
///
/// This persisted value will be useful by following reasons:
///
///     1) Clients know nothing about storage type
///     2) Ability to store any model
///     3) Extendable by a lot of operators
///
/// For example we can create a persisted value and apply different operators:
///
///     let persistedValue = storage.persistedValue(forKey: "key")
///         // store Codable types
///         .codable(Model.self)
///         // provides default value
///         .default(Model())
///         // print setters and getter in console
///         .print()
///
///     // reads current value
///     let model = persistedValue.wrappedValue
///
///     // writes a new value
///     persistedValue.wrappedValue = Model()
///
@dynamicMemberLookup
public protocol PersistedValue {
    associatedtype Value

    /// A actual value that stored in storage.
    ///
    /// Thought this property possible to read and write value to storage.
    /// In most cases it is computated property. It means that each `get` call directly pointed to request value from storage.
    var wrappedValue: Value { get nonmutating set }

    /// Safe method to change current value.
    ///
    /// - Parameter transform: The closure that accept  mutatable value.
    func mutate(_ transform: (inout Value) -> ())
}


/// Domain to handle all possible types of `PersistedValue`
public enum PersistedValues {}

public extension PersistedValue {

    /// Default implementation of `mutate(_:)`.
    ///
    /// To have thread-safe persisted value, check `PersistedValues.Atomic` type.
    func mutate(_ transform: (inout Value) -> ()) {
        transform(&wrappedValue)
    }

    /// dynamicMemberLookup implementation.
    ///
    /// This implementatiion allow you to have persisted value by writable key path.
    /// For example:
    ///
    ///     struct User: Codable {
    ///         var name: String
    ///     }
    ///
    ///     let persistedName = storage.persistedValue(forKey: "user")
    ///         .codable(Model.self)
    ///         .name
    ///
    ///     persistedName.wrappedValue = "new name"
    ///
    ///     print(storage.persistedValue(forKey: "user").codable(Model.self).wrappedValue?.name)
    ///     // "new name"
    ///
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> AnyPersistedValue<Subject> {
        .init(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}
