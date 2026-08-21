import AppKit
import SwiftUI

/// Manages the status bar item and its dropdown directly with NSStatusItem +
/// NSPopover instead of SwiftUI's MenuBarExtra. NSPopover's own show/performClose
/// correctly synchronizes the status item's highlighted state; MenuBarExtra's
/// panel does not expose a way to do that when closed programmatically, which
/// left the button stuck highlighted and required an extra click to reopen.
@MainActor
final class MenuBarPopoverController: NSObject {
    static let shared = MenuBarPopoverController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    private override init() {}

    func setup(viewModel: ProfilesViewModel) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "switch.2", accessibilityDescription: "Zwix")
            button.action = #selector(togglePopover)
            button.target = self
        }
        statusItem = item

        let pop = NSPopover()
        pop.behavior = .transient
        pop.contentViewController = NSHostingController(rootView: MenuBarContentView().environmentObject(viewModel))
        popover = pop
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func close() {
        popover?.performClose(nil)
    }
}
