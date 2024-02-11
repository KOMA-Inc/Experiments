public protocol BaselineBoolRemoteValue: RemoteValue {
    init?(rawValue: String)
    var baseline: Bool { get }
}
