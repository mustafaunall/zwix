import AppKit
import SwiftUI
import Combine

/// Manages the status bar item and its dropdown directly with NSStatusItem +
/// NSPopover instead of SwiftUI's MenuBarExtra. NSPopover's own show/performClose
/// correctly synchronizes the status item's highlighted state; MenuBarExtra's
/// panel does not expose a way to do that when closed programmatically, which
/// left the button stuck highlighted and required an extra click to reopen.
@MainActor
final class MenuBarPopoverController: NSObject {
    static let shared = MenuBarPopoverController()

    private static let defaultSymbolName = "switch.2"

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private weak var viewModel: ProfilesViewModel?
    private var cancellables = Set<AnyCancellable>()

    private override init() {}

    func setup(viewModel: ProfilesViewModel) {
        self.viewModel = viewModel

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.action = #selector(togglePopover)
        item.button?.target = self
        statusItem = item

        let pop = NSPopover()
        pop.behavior = .transient
        pop.contentViewController = NSHostingController(rootView: MenuBarContentView().environmentObject(viewModel))
        popover = pop

        updateStatusIcon()
        viewModel.$activeProfileID
            .combineLatest(viewModel.$profiles)
            .sink { [weak self] _, _ in
                self?.updateStatusIcon()
            }
            .store(in: &cancellables)
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

    private func updateStatusIcon() {
        let symbolName = viewModel?.activeProfile?.iconName ?? Self.defaultSymbolName
        statusItem?.button?.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Zwix")
    }
}
