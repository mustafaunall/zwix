import AppKit

enum RunningAppsProvider {
    /// Includes regular apps AND menu-bar-only/accessory apps (Stats, Ice, AltTab, etc.)
    /// since those are exactly the kind of background utilities this app targets.
    /// Excludes only .prohibited (invisible daemons with no UI).
    static func allUserVisibleApps() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy != .prohibited }
            .filter { $0.bundleIdentifier != nil }
            .filter { $0.bundleIdentifier != Bundle.main.bundleIdentifier }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }
}
