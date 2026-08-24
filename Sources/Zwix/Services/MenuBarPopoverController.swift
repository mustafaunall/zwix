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
    private var hostingController: NSHostingController<AnyView>?
    private weak var viewModel: ProfilesViewModel?
    private var cancellables = Set<AnyCancellable>()

    private override init() {}

    func setup(viewModel: ProfilesViewModel) {
        guard statusItem == nil else { return }
        self.viewModel = viewModel

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.action = #selector(togglePopover)
        item.button?.target = self
        statusItem = item

        let hosting = NSHostingController(
            rootView: AnyView(MenuBarContentView(activeProfileID: viewModel.activeProfileID).environmentObject(viewModel))
        )
        hostingController = hosting

        let pop = NSPopover()
        pop.behavior = .transient
        pop.contentViewController = hosting
        popover = pop

        refresh(activeProfileID: viewModel.activeProfileID, profiles: viewModel.profiles)

        // SwiftUI's @EnvironmentObject reactivity is not reliable for this
        // NSHostingController hosted inside a manually-driven NSPopover —
        // the dropdown's checkmark has been observed staying stale even
        // while the popover is currently open, not just on reopen. Combine
        // delivering values directly, and manually re-injecting a fresh
        // rootView on every change, has been reliable throughout testing
        // (it's what already drives the status bar icon correctly), so
        // drive the dropdown content the same way instead of trusting
        // SwiftUI's own diffing here.
        //
        // Also: @Published's publisher fires from willSet, before the
        // stored property is actually mutated, so the delivered values
        // (not a re-read of viewModel) must be used.
        viewModel.$activeProfileID
            .combineLatest(viewModel.$profiles)
            .sink { [weak self] activeProfileID, profiles in
                self?.refresh(activeProfileID: activeProfileID, profiles: profiles)
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover, let viewModel else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            refresh(activeProfileID: viewModel.activeProfileID, profiles: viewModel.profiles)
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func close() {
        popover?.performClose(nil)
    }

    private func refresh(activeProfileID: UUID?, profiles: [Profile]) {
        let symbolName = profiles.first(where: { $0.id == activeProfileID })?.iconName ?? Self.defaultSymbolName
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Zwix")
            // Force an immediate repaint instead of relying on whatever
            // display cycle AppKit would otherwise coalesce this into —
            // the icon was observed lagging one change behind visually
            // even though the underlying image was already reassigned.
            button.needsDisplay = true
        }

        guard let viewModel else { return }
        hostingController?.rootView = AnyView(
            MenuBarContentView(activeProfileID: activeProfileID).environmentObject(viewModel)
        )
    }
}
