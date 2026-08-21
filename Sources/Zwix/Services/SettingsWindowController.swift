import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private var windowController: NSWindowController?
    private var isShown = false

    private override init() {}

    func toggle(viewModel: ProfilesViewModel) {
        if isShown {
            windowController?.window?.orderOut(nil)
            isShown = false
        } else {
            show(viewModel: viewModel)
        }
    }

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
            window.delegate = self
            windowController = NSWindowController(window: window)
        }

        NSApp.activate(ignoringOtherApps: true)
        windowController?.showWindow(nil)
        windowController?.window?.makeKeyAndOrderFront(nil)
        isShown = true
    }

    func windowWillClose(_ notification: Notification) {
        isShown = false
    }
}
