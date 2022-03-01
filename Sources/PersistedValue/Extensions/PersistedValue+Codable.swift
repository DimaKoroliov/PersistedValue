import Foundation

private let jsonEncoder = JSONEncoder()
private let jsonDecoder = JSONDecoder()

public extension PersistedValue where Value == Data? {

    func codable<T>(
        _ type: T.Type = T.self
    ) -> PersistedValues.Map<Self, T?> where T: Codable {
        self.codable(type, encoder: jsonEncoder, decoder: jsonDecoder)
    }

    func codable<T>(
        _ type: T.Type = T.self,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) -> PersistedValues.Map<Self, T?> where T: Codable {
        self.map(
            transform: { $0.flatMap { try? decoder.decode(T.self, from: $0) } },
            untransform: { $0.flatMap { try? encoder.encode($0) } }
        )
    }
}
