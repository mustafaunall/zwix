import SwiftUI

struct ProtectedAppsView: View {
    @EnvironmentObject var viewModel: ProfilesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAppPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Protected Apps", systemImage: "lock.shield")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }

            Text("These apps are never closed by Zwix, no matter what profile is active.")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Always protected").font(.subheadline.weight(.semibold))
                Text("Finder, Dock, and Zwix itself — not editable.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Your allowlist").font(.subheadline.weight(.semibold))
                    Spacer()
                    Button("Add App…") { showAppPicker = true }
                }
                if viewModel.neverCloseApps.isEmpty {
                    Text("None").font(.caption).foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.neverCloseApps) { entry in
                        HStack {
                            Text(entry.displayName)
                            Spacer()
                            Button {
                                viewModel.removeNeverCloseApp(entry)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 360, height: 380)
        .sheet(isPresented: $showAppPicker) {
            AppPickerView(mode: .multiSelect(initial: viewModel.neverCloseApps, onDone: { entries in
                for entry in entries {
                    viewModel.addNeverCloseApp(entry)
                }
            }), title: "Add app to allowlist")
        }
    }
}
