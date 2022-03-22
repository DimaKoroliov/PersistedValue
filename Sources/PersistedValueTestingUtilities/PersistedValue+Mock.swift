import PersistedValue

public final class MockPersistedValue<Value>: PersistedValue {
    public private(set) var inputs: [Value] = []
    public var outputsCount = 0
    public var output: Value

    public var wrappedValue: Value {
        get {
            self.outputsCount += 1
            return self.output
        }
        
        set {
            self.inputs.append(newValue)
            self.output = newValue
        }
    }

    public init(_ output: Value) {
        self.output = output
    }
}
