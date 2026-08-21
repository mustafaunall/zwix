import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let viewModel = ProfilesViewModel()
    private var triggerWatcher: TriggerWatcher?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let watcher = TriggerWatcher(viewModel: viewModel)
        watcher.start()
        triggerWatcher = watcher
        MenuBarPopoverController.shared.setup(viewModel: viewModel)
    }
}
