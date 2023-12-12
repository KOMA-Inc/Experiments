public protocol RemoteKey {
    var name: String { get }
    var valueType: RemoteConfigValue.Type { get }
}
