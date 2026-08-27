import SwiftUI

struct ProfileDetailEditor: View {
    @EnvironmentObject var viewModel: ProfilesViewModel
    let profileID: UUID

    @State private var showOpenPicker = false
    @State private var showClosePicker = false
    @State private var showTriggerPicker = false
    @State private var triggerConflictMessage: String?
    @State private var showWorkspaceAppPicker = false
    @State private var pendingWorkspaceApp: AppEntry?
    @State private var pendingWorkspaceKeyword = ""

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

                card(title: "Trigger Apps", systemImage: "bolt.circle") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Launching any of these apps automatically activates this profile.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        appListSection(entries: profile.triggerApps, addAction: { showTriggerPicker = true }) { entry in
                            binding.triggerApps.wrappedValue.removeAll { $0.id == entry.id }
                        }
                        if let msg = triggerConflictMessage {
                            Text(msg).font(.caption).foregroundColor(.red)
                        }
                    }
                }

                card(title: "Workspace Triggers", systemImage: "folder.badge.gearshape") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activates this profile when the app is frontmost and its window title contains the keyword — e.g. VS Code + \"zwix\" only fires for that project folder.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        workspaceTriggerListSection()
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
            AppPickerView(mode: .multiSelect(initial: profile.triggerApps, onDone: { entries in
                let conflicts = entries.filter { viewModel.isTriggerAppTaken($0.bundleIdentifier, excluding: profileID) }
                let accepted = entries.filter { !viewModel.isTriggerAppTaken($0.bundleIdentifier, excluding: profileID) }
                binding.triggerApps.wrappedValue = accepted
                triggerConflictMessage = conflicts.isEmpty
                    ? nil
                    : "\(conflicts.map(\.displayName).joined(separator: ", ")) already used by another profile."
            }), title: "Assign trigger apps")
        }
        .sheet(isPresented: $showWorkspaceAppPicker) {
            AppPickerView(mode: .selectSingle(onSelect: { entry in
                pendingWorkspaceApp = entry
            }), title: "Pick app for workspace trigger")
        }
        .sheet(item: $pendingWorkspaceApp) { app in
            workspaceKeywordSheet(for: app)
        }
    }

    @ViewBuilder
    private func workspaceTriggerListSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if profile.workspaceTriggers.isEmpty {
                Text("None").font(.caption).foregroundColor(.secondary)
            } else {
                ForEach(profile.workspaceTriggers) { trigger in
                    HStack {
                        Text("\(trigger.app.displayName) — \"\(trigger.keyword)\"")
                        Spacer()
                        Button {
                            binding.workspaceTriggers.wrappedValue.removeAll { $0.id == trigger.id }
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Button("Add Workspace Trigger…") { showWorkspaceAppPicker = true }
                .padding(.top, profile.workspaceTriggers.isEmpty ? 0 : 4)
        }
    }

    @ViewBuilder
    private func workspaceKeywordSheet(for app: AppEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workspace keyword").font(.headline)
            Text("Text to look for in \(app.displayName)'s window title (e.g. a folder or project name).")
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("Folder or project name", text: $pendingWorkspaceKeyword)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                Button("Cancel") {
                    pendingWorkspaceApp = nil
                    pendingWorkspaceKeyword = ""
                }
                Button("Add") {
                    let keyword = pendingWorkspaceKeyword.trimmingCharacters(in: .whitespaces)
                    guard !keyword.isEmpty else { return }
                    binding.workspaceTriggers.wrappedValue.append(WorkspaceTrigger(app: app, keyword: keyword))
                    pendingWorkspaceApp = nil
                    pendingWorkspaceKeyword = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(pendingWorkspaceKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
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
