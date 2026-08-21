import SwiftUI

@main
struct ZwixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Zwix", systemImage: "switch.2") {
            MenuBarContentView()
                .environmentObject(appDelegate.viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
