import AppKit
import UniformTypeIdentifiers

enum ProfileFileIO {
    static func exportPanel(suggestedName: String) -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(suggestedName).json"
        guard panel.runModal() == .OK else { return nil }
        return panel.url
    }

    static func importPanel() -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK else { return nil }
        return panel.url
    }
}
