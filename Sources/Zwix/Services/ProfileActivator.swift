import AppKit

enum ProfileActivator {
    static func activate(_ target: Profile, deactivating previous: Profile?, protectedBundleIDs: Set<String> = []) async {
        if let previous {
            let targetOpenIDs = Set(target.openApps.map(\.bundleIdentifier))
            let staleFromPrevious = previous.openApps.filter { !targetOpenIDs.contains($0.bundleIdentifier) }
            await AppTerminator.terminate(staleFromPrevious, protectedBundleIDs: protectedBundleIDs)
        }
        await AppTerminator.terminate(target.closeApps, protectedBundleIDs: protectedBundleIDs)

        let running = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        for entry in target.openApps where !running.contains(entry.bundleIdentifier) {
            openApp(entry)
        }
    }

    private static func openApp(_ entry: AppEntry) {
        guard let url = entry.bundleURL
                ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: entry.bundleIdentifier)
        else { return }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = false
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, _ in }
    }
}
