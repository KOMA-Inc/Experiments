import Combine

open class RemoteConfigService {

    private let remoteConfigKeeper: RemoteConfigKeeper

    private var missingKeys: [RemoteKey] = []
    private var incorrectValues: [(key: RemoteKey, value: String)] = []

    private var allKeys: [RemoteKey] = []

    public init(remoteConfigKeeper: RemoteConfigKeeper) {
        self.remoteConfigKeeper = remoteConfigKeeper
    }

    private struct StorageKey: Hashable {
        let identifier: RemoteValue.Type

        static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
            lhs.identifier == rhs.identifier
        }

        func hash(into hasher: inout Hasher) {
            ObjectIdentifier(identifier).hash(into: &hasher)
        }
    }

    @Atomic
    private var storage: [StorageKey: CurrentValueSubject<RemoteValue, Never>] = [:]

    @discardableResult
    private func getRemoteValue<T: RemoteValue>(for key: RemoteKey, with type: T.Type) -> T {
        // Create storage key for given value type
        let storageKey = StorageKey(identifier: type)

        // If value is cached, return it
        if let value = storage[storageKey]?.value as? T {
            return value
        }

        // Try to retrieve value from debug panel
        var remoteValue: T? = debugValue(for: key)

        // It it is absent, get real value
        if remoteValue == nil {
            remoteValue = remoteConfigKeeper.value(for: key)
        }

        // If it is still absent, either value is incorrect or key itself is missing
        if remoteValue == nil {
            // key has value, meaning that this value is incorrect
            if let stringValueRepresentation = remoteConfigKeeper.stringValueRepresentation(for: key) {
                incorrectValues.append((key: key, value: stringValueRepresentation))
                trackIncorrectValue(for: key, value: stringValueRepresentation)
            } else {
                // key does NOT have value, meaning it is missing
                missingKeys.append(key)
                trackKeyNotFound(key)
            }
        }

        // track value if needed
        if let trackableValue = remoteValue as? ExperimentalGroupTrackable, trackableValue.shouldTrack {
            trackExperimentalGroup(for: trackableValue)
        }

        // If remote value was not found, use default
        let value = remoteValue ?? .default

        // cache result
        storage[storageKey] = CurrentValueSubject(value)

        return value
    }

    @discardableResult
    private func getRemoteValuePublisher<T: RemoteValue>(
        for key: RemoteKey,
        with type: T.Type
    ) -> AnyPublisher<RemoteValue, Never> {
        let storageKey = StorageKey(identifier: type)
        guard let publisher = storage[storageKey] else {
            getRemoteValue(for: key, with: type)
            return storage[storageKey]!.eraseToAnyPublisher()
        }
        return publisher.eraseToAnyPublisher()
    }

    open func debugValue<T: RemoteValue>(for key: RemoteKey) -> T? {
        nil
    }

    /// Retrieves all the values and caches them. Sets up experimental groups, calling method ``trackExperimentalGroup(for:)``
    ///
    open func getValues(for keys: [RemoteKey]) {
        allKeys = keys
        keys.forEach { key in
            getRemoteValue(for: key, with: key.valueType)
        }
        if !missingKeys.isEmpty {
            trackKeysNotFound(missingKeys)
        }
        if !incorrectValues.isEmpty {
            trackIncorrectValues(incorrectValues)
        }
    }

    open func trackKeyNotFound(_ key: RemoteKey) {

    }

    open func trackKeysNotFound(_ keys: [RemoteKey]) {

    }

    open func trackIncorrectValue(for key: RemoteKey, value: String) {

    }

    open func trackIncorrectValues(_ data: [(key: RemoteKey, value: String)]) {

    }

    open func trackExperimentalGroup(for value: ExperimentalGroupTrackable) {

    }
}

public extension RemoteConfigService {

    final var currentRemoteData: [(key: String, value: String)] {
        allKeys.compactMap { key in
            let value = getRemoteValue(for: key, with: key.valueType)

            let keyTitle = if let key = key as? TitledRemoteKey {
                key.title
            } else {
                key.name
            }

            return if let value = value as? BoolRemoteValue {
                (key: keyTitle, value: value.rawValue == 0 ? "disabled" : "enabled")
            } else if let value = value as? StringRemoteValue {
                (key: keyTitle, value: value.name)
            } else {
                nil
            }
        }
    }

    final func remoteValue<T: RemoteValue>(for key: RemoteKey) -> T {
        getRemoteValue(for: key, with: key.valueType) as! T
    }

    final func remoteValuePublisher<T: RemoteValue>(for key: RemoteKey) -> AnyPublisher<T, Never> {
        getRemoteValuePublisher(for: key, with: key.valueType as! T.Type)
            .compactMap { $0 as? T }
            .share()
            .eraseToAnyPublisher()
    }

    final func fetch() -> AnyPublisher<Void, Error> {
        remoteConfigKeeper.fetch()
    }
}
