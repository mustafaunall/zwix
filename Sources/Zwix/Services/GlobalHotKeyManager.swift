import Carbon.HIToolbox
import AppKit

/// Registers a system-wide keyboard shortcut via the Carbon Hot Key Manager
/// (RegisterEventHotKey). Unlike NSEvent's global monitor, this doesn't
/// require Accessibility/Input Monitoring permission — it's a plain hotkey
/// registration, not raw keystroke capture, which is why menu bar utilities
/// have used this API for global shortcuts for years.
@MainActor
final class GlobalHotKeyManager {
    static let shared = GlobalHotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var action: (() -> Void)?

    private init() {}

    func register(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        self.action = action

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData -> OSStatus in
                guard let userData else { return noErr }
                // Carbon dispatches this on the main run loop, but the C
                // function pointer itself can't carry actor isolation —
                // assumeIsolated is safe here for the same reason it was
                // needed for the NotificationCenter block-based API.
                MainActor.assumeIsolated {
                    let manager = Unmanaged<GlobalHotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                    manager.action?()
                }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        let hotKeyID = EventHotKeyID(signature: OSType(bitPattern: 0x5A57_4958), id: 1) // 'ZWIX'
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }
}
