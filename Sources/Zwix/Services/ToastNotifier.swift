import Foundation
import UserNotifications

enum ToastNotifier {
    /// UNUserNotificationCenter hard-crashes (NSInternalInconsistencyException,
    /// "bundleProxyForCurrentProcess is nil") when the process has no real
    /// app bundle/CFBundleIdentifier — true for the raw binary `swift run`
    /// launches. Only the properly-bundled release .app (Scripts/build-app.sh)
    /// has one, so skip notifications entirely outside of that.
    private static var isProperlyBundled: Bool {
        Bundle.main.bundleIdentifier != nil
    }

    static func requestAuthorizationIfNeeded() {
        guard isProperlyBundled else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }

    static func notifyActivation(profileName: String, summary: ProfileActivator.Summary) {
        guard isProperlyBundled, summary.openedCount > 0 || summary.closedCount > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(profileName) activated"
        content.body = "\(summary.openedCount) app\(summary.openedCount == 1 ? "" : "s") opened, "
            + "\(summary.closedCount) app\(summary.closedCount == 1 ? "" : "s") closed"

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
