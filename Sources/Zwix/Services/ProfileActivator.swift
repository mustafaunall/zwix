import AppKit

enum ProfileActivator {
    struct Summary {
        var openedCount: Int
        var closedCount: Int
    }

    @discardableResult
    static func activate(
        _ target: Profile,
        deactivating previous: Profile?,
        protectedBundleIDs: Set<String> = [],
        gracePeriod: TimeInterval = PersistedState.defaultTerminationGracePeriod
    ) async -> Summary {
        var closedCount = 0
        if let previous {
            let targetOpenIDs = Set(target.openApps.map(\.bundleIdentifier))
            let staleFromPrevious = previous.openApps.filter { !targetOpenIDs.contains($0.bundleIdentifier) }
            closedCount += await AppTerminator.terminate(staleFromPrevious, protectedBundleIDs: protectedBundleIDs, gracePeriod: gracePeriod)
        }
        closedCount += await AppTerminator.terminate(target.closeApps, protectedBundleIDs: protectedBundleIDs, gracePeriod: gracePeriod)

        let running = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        var openedCount = 0
        for entry in target.openApps where !running.contains(entry.bundleIdentifier) {
            openApp(entry)
            openedCount += 1
        }

        return Summary(openedCount: openedCount, closedCount: closedCount)
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
