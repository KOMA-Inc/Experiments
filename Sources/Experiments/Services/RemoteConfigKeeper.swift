import Combine

public protocol RemoteConfigKeeper {
    func value<T: RemoteValue>(for key: RemoteKey) -> T?
    func stringValueRepresentation(for key: RemoteKey) -> String?
    func fetch() -> AnyPublisher<Void, Error>
}
