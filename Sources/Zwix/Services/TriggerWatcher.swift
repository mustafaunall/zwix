import AppKit

@MainActor
final class TriggerWatcher {
    private var launchObserver: NSObjectProtocol?
    private var terminateObserver: NSObjectProtocol?
    private weak var viewModel: ProfilesViewModel?

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
            Task { @MainActor in
                self?.handleLaunch(note)
            }
        }
        terminateObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            Task { @MainActor in
                self?.handleTerminate(note)
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
        launchObserver = nil
        terminateObserver = nil
    }

    private func handleLaunch(_ notification: Notification) {
        guard let vm = viewModel,
              let launched = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = launched.bundleIdentifier,
              let matched = vm.profiles.first(where: { $0.triggerApp?.bundleIdentifier == bundleID }),
              vm.activeProfileID != matched.id
        else { return }
        Task { await vm.activate(profile: matched) }
    }

    /// If the currently active profile's trigger app is the one that just quit,
    /// drop back to no-profile-active state.
    private func handleTerminate(_ notification: Notification) {
        guard let vm = viewModel,
              let terminated = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = terminated.bundleIdentifier,
              let active = vm.activeProfile,
              active.triggerApp?.bundleIdentifier == bundleID
        else { return }
        vm.deactivateCurrent()
    }
}
