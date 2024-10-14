import Combine
import Experiments
import FirebaseRemoteConfig

public class FirebaseRemoteConfigKeeper: RemoteConfigKeeper {

    private enum Constant {
        static let expirationDuration: TimeInterval = 12 * 60 * 60
    }

    public init() { }

    // MARK: - Properties

    private lazy var config = RemoteConfig.remoteConfig()

    public func fetch() -> AnyPublisher<Void, Swift.Error> {
        let subject = PassthroughSubject<Void, Swift.Error>()

        DispatchQueue.global().async {
            self.config.fetchAndActivate { _, error in
                if let error {
                    subject.send(completion: .failure(error))
                } else {
                    subject.send(completion: .finished)
                }
            }
        }

        return subject.eraseToAnyPublisher()
    }

    public func value<T: Experiments.RemoteValue>(for key: Experiments.RemoteKey) -> T? {
        if let type = key.valueType as? StringInitializableRemoteValue.Type {
            return string(for: key).flatMap { type.init(name: $0) } as? T
        } else if let type = key.valueType as? BoolInitializableRemoteValue.Type {
            return bool(for: key).flatMap { type.init(booleanLiteral: $0) } as? T
        }
        return nil
    }

    public func stringValueRepresentation(for key: Experiments.RemoteKey) -> String? {
        if let value = string(for: key) {
            return value.isEmpty ? nil : value
        }
        return nil
    }

    private func int(for key: Experiments.RemoteKey) -> Int {
        config[key.name].numberValue.intValue
    }

    private func bool(for key: Experiments.RemoteKey) -> Bool? {
        let stringValue = config[key.name].stringValue
        guard !stringValue.isEmpty else {
            return nil
        }

        return stringValue == "true"
    }

    private func string(for key: Experiments.RemoteKey) -> String? {
        config[key.name].stringValue
    }
}
