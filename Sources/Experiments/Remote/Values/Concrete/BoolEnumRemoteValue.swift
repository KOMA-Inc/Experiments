public protocol BoolEnumRemoteValue: BoolRemoteValue {
    static var enabled: Self { get }
    static var disabled: Self { get }
}

public extension BoolEnumRemoteValue {
    init(booleanLiteral value: Bool) {
        self = value ? .enabled : .disabled
    }

    static var `default`: Self {
        disabled
    }
}

public extension BoolEnumRemoteValue where Self: Equatable {

    var isEnabled: Bool {
        self == .enabled
    }
}
