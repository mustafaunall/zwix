import AppKit
import ApplicationServices

/// Reads the frontmost window title of a running app via the Accessibility
/// API. Unlike GlobalHotKeyManager's Carbon hotkey (which needs no special
/// permission), this genuinely requires the user to grant Zwix Accessibility
/// access in System Settings — there's no lighter-weight API for reading
/// another app's window title on macOS.
enum WindowTitleInspector {
    /// Prompts the user with the system Accessibility-permission dialog if
    /// Zwix isn't trusted yet. Safe to call repeatedly — macOS only shows
    /// the prompt once per launch.
    @discardableResult
    static func requestAccessIfNeeded() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static var hasAccess: Bool {
        AXIsProcessTrusted()
    }

    /// Title of `app`'s frontmost window, or nil if the app isn't running,
    /// has no window, or Zwix lacks Accessibility permission.
    static func frontmostWindowTitle(for app: NSRunningApplication) -> String? {
        guard hasAccess else { return nil }
        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        var window: AnyObject?
        let windowResult = AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &window)
        guard windowResult == .success, let window else { return nil }

        var title: AnyObject?
        let titleResult = AXUIElementCopyAttributeValue(window as! AXUIElement, kAXTitleAttribute as CFString, &title)
        guard titleResult == .success else { return nil }
        return title as? String
    }
}
