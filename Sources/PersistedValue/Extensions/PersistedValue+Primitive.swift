import Foundation

public extension PersistedValue where Value == Data? {

    func string(using encoding: String.Encoding = .utf8) -> PersistedValues.Map<Self, String?> {
        self.map(
            transform: { $0.flatMap { String(data: $0, encoding: encoding) } },
            untransform: { $0.flatMap { $0.data(using: encoding) } }
        )
    }

    func integer<T>(_ type: T.Type) -> PersistedValues.Map<PersistedValues.Map<Self, String?>, T?> where T: FixedWidthInteger {
        self.string()
            .map(
                transform: { $0.flatMap(T.init) },
                untransform: { $0.flatMap { "\($0)" } }
            )
    }
}
