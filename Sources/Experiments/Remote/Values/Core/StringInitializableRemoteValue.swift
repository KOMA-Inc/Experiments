public protocol StringInitializableRemoteValue: RemoteValue {
    init?(name: String)
    var name: String { get }
}

public extension StringInitializableRemoteValue where Self: RawRepresentable, Self.RawValue == String {

    var name: String { rawValue }

    init?(name: String) {
        self.init(rawValue: name)
    }
}
