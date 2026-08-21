import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var windowController: NSWindowController?

    private init() {}

    /// Always activates the app and brings the Settings window to front,
    /// creating it if needed. Matches standard macOS Settings/Preferences
    /// behavior — this never hides the window; closing is left to the
    /// window's own close button or Cmd+W.
    func show(viewModel: ProfilesViewModel) {
        if windowController == nil {
            let root = SettingsRootView().environmentObject(viewModel)
            let hosting = NSHostingController(rootView: root)
            let window = NSWindow(contentViewController: hosting)
            window.title = "Zwix Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 640, height: 440))
            window.minSize = NSSize(width: 540, height: 360)
            window.center()
            window.isReleasedWhenClosed = false
            windowController = NSWindowController(window: window)
        }

        NSApp.activate(ignoringOtherApps: true)
        windowController?.showWindow(nil)
        windowController?.window?.makeKeyAndOrderFront(nil)
    }
}
