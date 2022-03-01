import PersistedValue

public final class MockPersistedValue<Value>: PersistedValue {
    public private(set) var inputs: [Value] = []
    public var outputsCount: Int = 0
    public var output: Value

    public var wrappedValue: Value {
        get {
            self.outputsCount = 0
            return self.output
        }
        
        set {
            self.inputs.append(newValue)
        }
    }

    public init(_ output: Value) {
        self.output = output
    }
}
