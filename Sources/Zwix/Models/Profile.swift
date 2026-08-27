import Foundation

struct AppEntry: Codable, Identifiable, Hashable {
    var id: String { bundleIdentifier }
    let bundleIdentifier: String
    let displayName: String
    let bundleURL: URL?
}

/// Pairs a trigger app with a keyword/path that must appear in that app's
/// frontmost window title — e.g. VS Code with "zwix" only fires the profile
/// when the *Zwix* project folder is open, not on any VS Code launch.
struct WorkspaceTrigger: Codable, Identifiable, Hashable {
    var id: UUID
    var app: AppEntry
    var keyword: String

    init(id: UUID = UUID(), app: AppEntry, keyword: String) {
        self.id = id
        self.app = app
        self.keyword = keyword
    }
}

struct Profile: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var iconName: String
    var openApps: [AppEntry]
    var closeApps: [AppEntry]
    var triggerApps: [AppEntry]
    var workspaceTriggers: [WorkspaceTrigger]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = ProfileIcons.defaultIcon,
        openApps: [AppEntry] = [],
        closeApps: [AppEntry] = [],
        triggerApps: [AppEntry] = [],
        workspaceTriggers: [WorkspaceTrigger] = []
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.openApps = openApps
        self.closeApps = closeApps
        self.triggerApps = triggerApps
        self.workspaceTriggers = workspaceTriggers
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, iconName, openApps, closeApps, triggerApps, workspaceTriggers
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
        workspaceTriggers = try c.decodeIfPresent([WorkspaceTrigger].self, forKey: .workspaceTriggers) ?? []
    }
}

struct PersistedState: Codable {
    static let defaultTerminationGracePeriod: TimeInterval = 2.0

    var profiles: [Profile]
    var activeProfileID: UUID?
    var neverCloseApps: [AppEntry] = []
    var terminationGracePeriod: TimeInterval = defaultTerminationGracePeriod
    var confirmBeforeSwitch: Bool = false

    private enum CodingKeys: String, CodingKey {
        case profiles, activeProfileID, neverCloseApps, terminationGracePeriod, confirmBeforeSwitch
    }

    init(
        profiles: [Profile],
        activeProfileID: UUID?,
        neverCloseApps: [AppEntry] = [],
        terminationGracePeriod: TimeInterval = defaultTerminationGracePeriod,
        confirmBeforeSwitch: Bool = false
    ) {
        self.profiles = profiles
        self.activeProfileID = activeProfileID
        self.neverCloseApps = neverCloseApps
        self.terminationGracePeriod = terminationGracePeriod
        self.confirmBeforeSwitch = confirmBeforeSwitch
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        profiles = try c.decode([Profile].self, forKey: .profiles)
        activeProfileID = try c.decodeIfPresent(UUID.self, forKey: .activeProfileID)
        neverCloseApps = try c.decodeIfPresent([AppEntry].self, forKey: .neverCloseApps) ?? []
        terminationGracePeriod = try c.decodeIfPresent(TimeInterval.self, forKey: .terminationGracePeriod)
            ?? Self.defaultTerminationGracePeriod
        confirmBeforeSwitch = try c.decodeIfPresent(Bool.self, forKey: .confirmBeforeSwitch) ?? false
    }
}
