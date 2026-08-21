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
    var triggerApp: AppEntry?

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = ProfileIcons.defaultIcon,
        openApps: [AppEntry] = [],
        closeApps: [AppEntry] = [],
        triggerApp: AppEntry? = nil
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.openApps = openApps
        self.closeApps = closeApps
        self.triggerApp = triggerApp
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, iconName, openApps, closeApps, triggerApp
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        iconName = try c.decodeIfPresent(String.self, forKey: .iconName) ?? ProfileIcons.defaultIcon
        openApps = try c.decodeIfPresent([AppEntry].self, forKey: .openApps) ?? []
        closeApps = try c.decodeIfPresent([AppEntry].self, forKey: .closeApps) ?? []
        triggerApp = try c.decodeIfPresent(AppEntry.self, forKey: .triggerApp)
    }
}

struct PersistedState: Codable {
    var profiles: [Profile]
    var activeProfileID: UUID?
}
