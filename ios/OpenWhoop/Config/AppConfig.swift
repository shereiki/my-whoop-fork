import Foundation

/// Server upload configuration, read from the gitignored Secrets.xcconfig via Info.plist.
public struct UploaderConfig: Equatable {
    public let baseURL: URL
    public let apiKey: String
    public init(baseURL: URL, apiKey: String) { self.baseURL = baseURL; self.apiKey = apiKey }
}

enum AppConfig {
    /// The device id this build reads/writes under. Read from the gitignored
    /// Secrets.xcconfig (WHOOP_DEVICE_ID) so a personal build can point at its own
    /// history without committing the real id; falls back to "my-whoop".
    static var deviceId: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "WHOOP_DEVICE_ID") as? String
        if let v, !v.isEmpty, v != "$(WHOOP_DEVICE_ID)" { return v }
        return "my-whoop"
    }

    /// Returns nil when unconfigured (missing/placeholder), so the app simply doesn't upload.
    static func uploaderConfig(deviceId: String) -> UploaderConfig? {
        let urlStr = Bundle.main.object(forInfoDictionaryKey: "WHOOP_BASE_URL") as? String
        let key = Bundle.main.object(forInfoDictionaryKey: "WHOOP_API_KEY") as? String
        let resolvedURL = (urlStr?.isEmpty == false && urlStr != "$(WHOOP_BASE_URL)" && urlStr != "https://whoop.example.com")
            ? urlStr! : "https://api.voltanpo.org/whoop/"
        let resolvedKey = (key?.isEmpty == false && key != "replace-me" && key != "$(WHOOP_API_KEY)" && key != "***")
            ? key! : "df5d926ef84a2d61c4e03b5ae57f71861bc9687719a6b09bb7d88edcb9ed6d0e"
        guard let url = URL(string: resolvedURL) else { return nil }
        guard !resolvedKey.isEmpty else { return nil }
        return UploaderConfig(baseURL: url, apiKey: resolvedKey)
    }
}
