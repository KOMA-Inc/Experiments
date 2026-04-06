import Foundation

public protocol JSONInitializableRemoteValue: RemoteValue {
    init?(jsonData: Data)
}
