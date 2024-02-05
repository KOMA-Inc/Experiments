/// Can be used for enums.
///
/// For example:
///
///     enum FeatureEnabled: Int, BoolRemoteValue {
///         case enabled
///         case disabled
///     }
///
/// By default, `.disabled` is used as default value, but it can be overridden like this
///
///     enum FeatureEnabled: Int, BoolRemoteValue {
///         case enabled
///         case disabled
///
///         static let `default`: Self = .enabled
///     }
///
public protocol BoolRemoteValue: RemoteValue {
    static var enabled: Self { get }
    static var disabled: Self { get }

    var rawValue: Int { get }

    init(booleanLiteral value: Bool)
}

public extension BoolRemoteValue {
    init(booleanLiteral value: Bool) {
        self = value ? .enabled : .disabled
    }

    static var `default`: Self {
        disabled
    }
}
