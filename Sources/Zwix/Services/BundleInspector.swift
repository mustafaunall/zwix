import AppKit
import UniformTypeIdentifiers

enum BundleInspector {
    static func pickAppFromDisk() -> AppEntry? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return entry(fromBundleAt: url)
    }

    static func entry(fromBundleAt url: URL) -> AppEntry? {
        guard let bundle = Bundle(url: url),
              let bundleID = bundle.bundleIdentifier else { return nil }
        let name = bundle.infoDictionary?["CFBundleName"] as? String
            ?? url.deletingPathExtension().lastPathComponent
        return AppEntry(bundleIdentifier: bundleID, displayName: name, bundleURL: url)
    }

    static func entry(fromRunning app: NSRunningApplication) -> AppEntry? {
        guard let bundleID = app.bundleIdentifier else { return nil }
        return AppEntry(
            bundleIdentifier: bundleID,
            displayName: app.localizedName ?? bundleID,
            bundleURL: app.bundleURL
        )
    }

    /// Scans standard app directories for installed .app bundles.
    /// This is the primary source for app pickers — running-process state
    /// isn't what the user wants when picking apps to open/close/trigger.
    static func installedApps() -> [AppEntry] {
        let searchDirs = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            NSHomeDirectory() + "/Applications"
        ]
        let fm = FileManager.default
        var seenBundleIDs = Set<String>()
        var results: [AppEntry] = []

        for dir in searchDirs {
            guard let items = try? fm.contentsOfDirectory(atPath: dir) else { continue }
            for item in items where item.hasSuffix(".app") {
                let url = URL(fileURLWithPath: dir).appendingPathComponent(item)
                guard let entry = entry(fromBundleAt: url),
                      !seenBundleIDs.contains(entry.bundleIdentifier)
                else { continue }
                seenBundleIDs.insert(entry.bundleIdentifier)
                results.append(entry)
            }
        }

        return results.sorted {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }
}
