import SwiftUI

@main
struct ZwixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No-op placeholder: App.body requires a Scene, but the status item
        // dropdown and Settings window are both managed manually in
        // AppDelegate/MenuBarPopoverController/SettingsWindowController.
        Settings {
            EmptyView()
        }
    }
}
