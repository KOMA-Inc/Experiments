import Experiments

public class FirebaseRemoteConfigService: RemoteConfigService {

    public init(remoteConfigKeeper: FirebaseRemoteConfigKeeper = FirebaseRemoteConfigKeeper()) {
        super.init(remoteConfigKeeper: remoteConfigKeeper)
    }
}
