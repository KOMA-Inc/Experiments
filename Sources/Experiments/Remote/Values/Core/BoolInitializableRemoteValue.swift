public protocol BoolInitializableRemoteValue: RemoteValue {
    
    var isEnabled: Bool { get }
    
    init(booleanLiteral value: Bool)
}
