import Combine
import Experiments
import FirebaseRemoteConfig

public class RemoteConfigKeeper {

    private enum Constant {
        static let expirationDuration: TimeInterval = 12 * 60 * 60
    }

    public static let shared = RemoteConfigKeeper()

    private init() {}

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

    public func value<T: Experiments.RemoteConfigValue>(for key: Experiments.RemoteKey) -> T? {
        if let type = key.valueType as? RemoteConfigStringValue.Type {
            return string(for: key).flatMap { type.init(rawValue: $0) } as? T
        } else if let type = key.valueType as? RemoteConfigBoolValue.Type {
            return bool(for: key).flatMap { type.init(booleanLiteral: $0) } as? T
        }
        return nil
    }

    private func int(for key: Experiments.RemoteKey) -> Int {
        config[key.name].numberValue.intValue
    }

    private func bool(for key: Experiments.RemoteKey) -> Bool? {
        guard
            let stringValue = config[key.name].stringValue,
            !stringValue.isEmpty else {
            return nil
        }

        return stringValue == "true"
    }

    private func string(for key: Experiments.RemoteKey) -> String? {
        config[key.name].stringValue
    }
}
