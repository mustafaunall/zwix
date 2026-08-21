import AppKit

enum AppTerminator {
    /// Apps that must never be terminated by Zwix, regardless of any profile
    /// or user-configured allowlist. Killing these can break the Finder/Dock
    /// or leave the user unable to manage their own machine.
    static let hardProtectedBundleIDs: Set<String> = [
        "com.apple.finder",
        "com.apple.dock",
        "com.apple.systemuiserver",
        Bundle.main.bundleIdentifier ?? "com.mustafaunal.zwix"
    ]

    @discardableResult
    static func terminate(_ entries: [AppEntry], protectedBundleIDs: Set<String> = []) async -> Int {
        let allProtected = hardProtectedBundleIDs.union(protectedBundleIDs)
        let targets = entries.filter { !allProtected.contains($0.bundleIdentifier) }

        let running = NSWorkspace.shared.runningApplications
        var toForceCheck: [NSRunningApplication] = []
        var killedCount = 0
        for entry in targets {
            guard let match = running.first(where: { $0.bundleIdentifier == entry.bundleIdentifier }),
                  !match.isTerminated else { continue }
            match.terminate()
            toForceCheck.append(match)
            killedCount += 1
        }
        guard !toForceCheck.isEmpty else { return killedCount }
        try? await Task.sleep(for: .seconds(2))
        for app in toForceCheck where !app.isTerminated {
            app.forceTerminate()
        }
        return killedCount
    }
}
