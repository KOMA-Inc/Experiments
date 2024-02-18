public protocol RemoteValue {
    static var `default`: Self { get }
}

public extension RemoteValue where Self: CaseIterable {
    static var `default`: Self {
        Self.allCases.first!
    }
}
