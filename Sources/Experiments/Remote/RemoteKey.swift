public protocol RemoteKey {
    var name: String { get }
    var valueType: RemoteValue.Type { get }
}

public extension RemoteKey where Self: RawRepresentable, Self.RawValue == String {

    var name: String {
        rawValue
    }
}

public protocol TitledRemoteKey: RemoteKey {
    var title: String { get }
}
