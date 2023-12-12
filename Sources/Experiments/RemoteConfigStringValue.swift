/// Can be used for enums.
///
/// For example:
///
///     enum PaywallScreenType: String, CaseIterable, RemoteConfigStringValue {
///         case featureDescription = "paywall_feature_description"
///         case videoHeader = "paywall_with_video_header"
///     }
///
/// By default the first case in enum is `deault`, but it can be overriden like this:
///
///     enum Foo: String, CaseIterable, RemoteConfigStringValue {
///         case a
///         case b
///         case c
///
///         static let `default`: Self = .c
///     }
///
public protocol RemoteConfigStringValue: RemoteConfigValue {
    init?(rawValue: String)
    var rawValue: String { get }
}

public extension RemoteConfigStringValue where Self: CaseIterable {
    static var `default`: Self {
        Self.allCases.first!
    }
}
