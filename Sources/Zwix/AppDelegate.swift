import AppKit
import Carbon.HIToolbox

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
        ToastNotifier.requestAuthorizationIfNeeded()

        // ⌥⌘Z — Spotlight-style quick access to the profile switcher
        // without reaching for the menu bar.
        GlobalHotKeyManager.shared.register(
            keyCode: UInt32(kVK_ANSI_Z),
            modifiers: UInt32(optionKey | cmdKey)
        ) {
            MenuBarPopoverController.shared.togglePopover()
        }
    }
}
