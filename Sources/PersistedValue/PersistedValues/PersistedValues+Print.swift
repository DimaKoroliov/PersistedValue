
public extension PersistedValue {

    func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> PersistedValues.Print<Self> {
        .init(self, prefix: prefix, to: stream)
    }
}

extension PersistedValues {

    public struct Print<Upstream>: PersistedValue where Upstream: PersistedValue {

        public typealias Value = Upstream.Value

        public var wrappedValue: Value {
            get {
                let value = self.upstream.wrappedValue
                self.stream.write("\(self.prefix)get value: (\(value))")
                return value
            }

            nonmutating set {
                self.stream.write("\(self.prefix)set value: (\(newValue))")
                self.upstream.wrappedValue = newValue
            }
        }

        private let upstream: Upstream
        private let prefix: String
        private var stream: TextStream

        init(_ upstream: Upstream, prefix: String = "", to stream: TextOutputStream? = nil) {
            self.upstream = upstream
            self.prefix = prefix.isEmpty ? "" : "\(prefix): "
            self.stream = TextStream(stream)
        }
    }
}

private class TextStream: TextOutputStream {

    var stream: TextOutputStream? = nil

    init(_ stream: TextOutputStream? = nil) {
        self.stream = stream
    }

    func write(_ string: String) {
        self.stream?.write(string) ?? print(string)
    }
}
