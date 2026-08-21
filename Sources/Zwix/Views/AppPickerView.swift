import SwiftUI
import AppKit

struct AppPickerView: View {
    enum Mode {
        case multiSelect(initial: [AppEntry], onDone: ([AppEntry]) -> Void)
        case selectSingle(onSelect: (AppEntry) -> Void)
    }

    let mode: Mode
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var installedApps: [AppEntry] = BundleInspector.installedApps()
    @State private var selected: [AppEntry] = []

    init(mode: Mode, title: String) {
        self.mode = mode
        self.title = title
        if case .multiSelect(let initial, _) = mode {
            _selected = State(initialValue: initial)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .padding([.horizontal, .top])

            DiskPickerButton {
                if let entry = BundleInspector.pickAppFromDisk() {
                    handlePick(entry)
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)

            Divider().padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(installedApps) { entry in
                        AppEntryRow(entry: entry, isSelected: isSelected(entry)) {
                            handlePick(entry)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .frame(minHeight: 220, maxHeight: 340)

            Divider()
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                if case .multiSelect(_, let onDone) = mode {
                    Button("Done") {
                        onDone(selected)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selected.isEmpty)
                }
            }
            .padding()
        }
        .frame(width: 340)
    }

    private func isSelected(_ entry: AppEntry) -> Bool {
        switch mode {
        case .multiSelect:
            return selected.contains { $0.bundleIdentifier == entry.bundleIdentifier }
        case .selectSingle:
            return false
        }
    }

    private func handlePick(_ entry: AppEntry) {
        switch mode {
        case .multiSelect:
            if let idx = selected.firstIndex(where: { $0.bundleIdentifier == entry.bundleIdentifier }) {
                selected.remove(at: idx)
            } else {
                selected.append(entry)
            }
        case .selectSingle(let onSelect):
            onSelect(entry)
            dismiss()
        }
    }
}

private struct DiskPickerButton: View {
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Label("Choose from Disk…", systemImage: "folder")
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.1), value: isHovering)
    }
}
