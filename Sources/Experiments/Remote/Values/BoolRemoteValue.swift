/// Can be used for enums.
///
/// For example:
///
///     enum FeatureEnabled: BoolRemoteValue {
///         case enabled
///         case disabled
///
///         static let `default`: Self = .enabled
///     }
///
public protocol BoolRemoteValue: RemoteValue {
    var rawValue: Bool { get }

    init(booleanLiteral value: Bool)
}

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
