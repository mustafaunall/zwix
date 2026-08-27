import AppKit

@MainActor
final class TriggerWatcher {
    private var launchObserver: NSObjectProtocol?
    private var terminateObserver: NSObjectProtocol?
    private var activationObserver: NSObjectProtocol?
    private var workspacePollTimer: Timer?
    private weak var viewModel: ProfilesViewModel?

    /// Polling (rather than an AXObserver per app) keeps this simple and
    /// covers the common case — a title changing because the user switched
    /// folders/workspaces in an already-running app — without juggling one
    /// observer per trigger app's lifecycle.
    private let workspacePollInterval: TimeInterval = 2

    init(viewModel: ProfilesViewModel) {
        self.viewModel = viewModel
    }

    func start() {
        guard launchObserver == nil else { return }
        launchObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            MainActor.assumeIsolated {
                self?.handleLaunch(note)
            }
        }
        terminateObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            MainActor.assumeIsolated {
                self?.handleTerminate(note)
            }
        }
        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkWorkspaceTriggers()
            }
        }
        workspacePollTimer = Timer.scheduledTimer(withTimeInterval: workspacePollInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkWorkspaceTriggers()
            }
        }
    }

    func stop() {
        if let launchObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(launchObserver)
        }
        if let terminateObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(terminateObserver)
        }
        if let activationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(activationObserver)
        }
        workspacePollTimer?.invalidate()
        launchObserver = nil
        terminateObserver = nil
        activationObserver = nil
        workspacePollTimer = nil
    }

    private func handleLaunch(_ notification: Notification) {
        guard let vm = viewModel,
              let launched = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = launched.bundleIdentifier,
              let matched = vm.profiles.first(where: { profile in
                  profile.triggerApps.contains { $0.bundleIdentifier == bundleID }
              }),
              vm.activeProfileID != matched.id
        else { return }
        Task { await vm.activate(profile: matched) }
    }

    /// If the currently active profile has no trigger app left running,
    /// drop back to no-profile-active state.
    private func handleTerminate(_ notification: Notification) {
        guard let vm = viewModel,
              let terminated = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = terminated.bundleIdentifier,
              let active = vm.activeProfile,
              active.triggerApps.contains(where: { $0.bundleIdentifier == bundleID })
        else { return }

        let stillRunning = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        let anyTriggerStillRunning = active.triggerApps.contains { stillRunning.contains($0.bundleIdentifier) }
        if !anyTriggerStillRunning {
            vm.deactivateCurrent()
        }
    }

    /// Matches the frontmost app's window title against every profile's
    /// workspace triggers. Only the frontmost app is checked — a background
    /// window's title isn't "the workspace you're in" the way the active
    /// one is, and reading every running app's title on each tick would be
    /// wasteful (and prompt-heavy the first time Accessibility access is
    /// requested).
    private func checkWorkspaceTriggers() {
        guard let vm = viewModel,
              WindowTitleInspector.hasAccess,
              let frontmost = NSWorkspace.shared.frontmostApplication,
              let frontmostBundleID = frontmost.bundleIdentifier
        else { return }

        guard let matched = vm.profiles.first(where: { profile in
            profile.workspaceTriggers.contains { trigger in
                guard trigger.app.bundleIdentifier == frontmostBundleID,
                      !trigger.keyword.trimmingCharacters(in: .whitespaces).isEmpty
                else { return false }
                guard let title = WindowTitleInspector.frontmostWindowTitle(for: frontmost) else { return false }
                return title.localizedCaseInsensitiveContains(trigger.keyword)
            }
        }), vm.activeProfileID != matched.id else { return }

        Task { await vm.activate(profile: matched) }
    }
}
