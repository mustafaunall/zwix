import SwiftUI

struct ProfileDetailEditor: View {
    @EnvironmentObject var viewModel: ProfilesViewModel
    let profileID: UUID

    @State private var showOpenPicker = false
    @State private var showClosePicker = false
    @State private var showTriggerPicker = false
    @State private var triggerConflictMessage: String?

    private var profile: Profile {
        viewModel.profiles.first(where: { $0.id == profileID }) ?? Profile(id: profileID, name: "")
    }

    private var binding: Binding<Profile> {
        Binding(
            get: { profile },
            set: { viewModel.updateProfile($0) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: profile.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.accentColor))

                    TextField("Profile name", text: binding.name)
                        .textFieldStyle(.plain)
                        .font(.title2.weight(.semibold))
                }
                .padding(.bottom, 4)

                card(title: "Icon", systemImage: "paintpalette") {
                    IconPickerGrid(selection: binding.iconName)
                }

                card(title: "Opens", systemImage: "arrow.up.forward.app") {
                    appListSection(entries: profile.openApps, addAction: { showOpenPicker = true }) { entry in
                        binding.openApps.wrappedValue.removeAll { $0.id == entry.id }
                    }
                }

                card(title: "Closes", systemImage: "xmark.app") {
                    appListSection(entries: profile.closeApps, addAction: { showClosePicker = true }) { entry in
                        binding.closeApps.wrappedValue.removeAll { $0.id == entry.id }
                    }
                }

                card(title: "Trigger App", systemImage: "bolt.circle") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Launching this app automatically activates this profile.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let trigger = profile.triggerApp {
                            HStack {
                                Text(trigger.displayName)
                                Spacer()
                                Button("Clear") { binding.triggerApp.wrappedValue = nil }
                            }
                        } else {
                            Button("Assign Trigger…") { showTriggerPicker = true }
                        }
                        if let msg = triggerConflictMessage {
                            Text(msg).font(.caption).foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(20)
        }
        .sheet(isPresented: $showOpenPicker) {
            AppPickerView(mode: .multiSelect(initial: profile.openApps, onDone: { entries in
                binding.openApps.wrappedValue = entries
            }), title: "Add app to Opens")
        }
        .sheet(isPresented: $showClosePicker) {
            AppPickerView(mode: .multiSelect(initial: profile.closeApps, onDone: { entries in
                binding.closeApps.wrappedValue = entries
            }), title: "Add app to Closes")
        }
        .sheet(isPresented: $showTriggerPicker) {
            AppPickerView(mode: .selectSingle(onSelect: { entry in
                if viewModel.isTriggerAppTaken(entry.bundleIdentifier, excluding: profileID) {
                    triggerConflictMessage = "\(entry.displayName) is already a trigger for another profile."
                } else {
                    triggerConflictMessage = nil
                    binding.triggerApp.wrappedValue = entry
                }
            }), title: "Assign trigger app")
        }
    }

    @ViewBuilder
    private func card<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.04))
        )
    }

    @ViewBuilder
    private func appListSection(entries: [AppEntry], addAction: @escaping () -> Void, onRemove: @escaping (AppEntry) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if entries.isEmpty {
                Text("None").font(.caption).foregroundColor(.secondary)
            } else {
                ForEach(entries) { entry in
                    HStack {
                        Text(entry.displayName)
                        Spacer()
                        Button {
                            onRemove(entry)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Button("Add App…", action: addAction)
                .padding(.top, entries.isEmpty ? 0 : 4)
        }
    }
}
