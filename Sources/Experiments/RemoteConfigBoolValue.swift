/// Can be used for enums.
///
/// For example:
///
///     enum FeatureEnabled: Int, RemoteConfigBoolValue {
///         case enabled
///         case disabled
///     }
///
/// By default, `.disabled` is used as default value, but it can be overriden like this
///
///     enum FeatureEnabled: Int, RemoteConfigBoolValue {
///         case enabled
///         case disabled
///
///         static let `default`: Self = .enabled
///     }
///
public protocol RemoteConfigBoolValue: RemoteConfigValue {
    static var enabled: Self { get }
    static var disabled: Self { get }

    var rawValue: Int { get }

    init(booleanLiteral value: Bool)
}

public extension RemoteConfigBoolValue {
    init(booleanLiteral value: Bool) {
        self = value ? .enabled : .disabled
    }

    static var `default`: Self {
        disabled
    }
}
