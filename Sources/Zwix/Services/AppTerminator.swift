import AppKit

enum AppTerminator {
    @discardableResult
    static func terminate(_ entries: [AppEntry]) async -> Int {
        let running = NSWorkspace.shared.runningApplications
        var toForceCheck: [NSRunningApplication] = []
        var killedCount = 0
        for entry in entries {
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
