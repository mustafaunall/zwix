import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AppEntryRow: View {
    let entry: AppEntry
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    private var icon: NSImage {
        if let path = entry.bundleURL?.path {
            return NSWorkspace.shared.icon(forFile: path)
        }
        return NSWorkspace.shared.icon(for: .applicationBundle)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 18, height: 18)
                Text(entry.displayName)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                        .bold()
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.1), value: isHovering)
    }
}
