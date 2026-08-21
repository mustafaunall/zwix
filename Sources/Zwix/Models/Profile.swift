import Foundation

struct AppEntry: Codable, Identifiable, Hashable {
    var id: String { bundleIdentifier }
    let bundleIdentifier: String
    let displayName: String
    let bundleURL: URL?
}

struct Profile: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var iconName: String
    var openApps: [AppEntry]
    var closeApps: [AppEntry]
    var triggerApps: [AppEntry]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = ProfileIcons.defaultIcon,
        openApps: [AppEntry] = [],
        closeApps: [AppEntry] = [],
        triggerApps: [AppEntry] = []
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.openApps = openApps
        self.closeApps = closeApps
        self.triggerApps = triggerApps
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, iconName, openApps, closeApps, triggerApps
    }

    private enum LegacyCodingKeys: String, CodingKey {
        case triggerApp
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        iconName = try c.decodeIfPresent(String.self, forKey: .iconName) ?? ProfileIcons.defaultIcon
        openApps = try c.decodeIfPresent([AppEntry].self, forKey: .openApps) ?? []
        closeApps = try c.decodeIfPresent([AppEntry].self, forKey: .closeApps) ?? []
        if let apps = try c.decodeIfPresent([AppEntry].self, forKey: .triggerApps) {
            triggerApps = apps
        } else {
            let legacy = try decoder.container(keyedBy: LegacyCodingKeys.self)
            if let legacyApp = try legacy.decodeIfPresent(AppEntry.self, forKey: .triggerApp) {
                triggerApps = [legacyApp]
            } else {
                triggerApps = []
            }
        }
    }
}

struct PersistedState: Codable {
    var profiles: [Profile]
    var activeProfileID: UUID?
    var neverCloseApps: [AppEntry] = []

    private enum CodingKeys: String, CodingKey {
        case profiles, activeProfileID, neverCloseApps
    }

    init(profiles: [Profile], activeProfileID: UUID?, neverCloseApps: [AppEntry] = []) {
        self.profiles = profiles
        self.activeProfileID = activeProfileID
        self.neverCloseApps = neverCloseApps
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        profiles = try c.decode([Profile].self, forKey: .profiles)
        activeProfileID = try c.decodeIfPresent(UUID.self, forKey: .activeProfileID)
        neverCloseApps = try c.decodeIfPresent([AppEntry].self, forKey: .neverCloseApps) ?? []
    }
}
