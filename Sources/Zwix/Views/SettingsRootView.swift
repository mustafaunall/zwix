import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject var viewModel: ProfilesViewModel
    @State private var selectedProfileID: UUID?
    @State private var showProtectedApps = false

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProfileID) {
                ForEach(viewModel.profiles) { profile in
                    SidebarProfileRow(profile: profile)
                        .tag(profile.id)
                        .contextMenu {
                            Button {
                                Task { await viewModel.applyCloseListNow(profile) }
                            } label: {
                                Label("Free RAM Now (close list)", systemImage: "wind")
                            }
                            Button(role: .destructive) {
                                deleteProfile(profile)
                            } label: {
                                Label("Delete Profile", systemImage: "trash")
                            }
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        deleteProfile(viewModel.profiles[index])
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        showProtectedApps = true
                    } label: {
                        Image(systemName: "lock.shield")
                    }
                    .help("Protected Apps")
                }
                ToolbarItem {
                    Button {
                        addProfile()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            if let id = selectedProfileID, viewModel.profiles.contains(where: { $0.id == id }) {
                ProfileDetailEditor(profileID: id)
                    .id(id)
            } else {
                Text("Select or create a profile")
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 620, minHeight: 380)
        .sheet(isPresented: $showProtectedApps) {
            ProtectedAppsView()
        }
    }

    private func addProfile() {
        let profile = viewModel.addProfile()
        selectedProfileID = profile.id
    }

    private func deleteProfile(_ profile: Profile) {
        if selectedProfileID == profile.id {
            selectedProfileID = nil
        }
        viewModel.deleteProfile(profile)
    }
}
