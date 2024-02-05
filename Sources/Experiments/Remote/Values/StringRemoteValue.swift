/// Can be used for enums.
///
/// For example:
///
///     enum PaywallScreenType: String, CaseIterable, StringRemoteValue {
///         case featureDescription = "paywall_feature_description"
///         case videoHeader = "paywall_with_video_header"
///     }
///
/// By default the first case in enum is `default`, but it can be overridden like this:
///
///     enum Foo: String, CaseIterable, StringRemoteValue {
///         case a
///         case b
///         case c
///
///         static let `default`: Self = .c
///     }
///
public protocol StringRemoteValue: RemoteValue {
    init?(name: String)
    var name: String { get }
}

public extension StringRemoteValue where Self: RawRepresentable, Self.RawValue == String {

    var name: String { rawValue }

    init?(name: String) {
        self.init(rawValue: name)
    }
}

public extension StringRemoteValue where Self: CaseIterable {
    static var `default`: Self {
        Self.allCases.first!
    }
}
