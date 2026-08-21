import AppKit
import Combine

@MainActor
final class ProfilesViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfileID: UUID?
    @Published var neverCloseApps: [AppEntry] = []

    private let store = ProfileStore()

    init() {
        let state = store.load()
        profiles = state.profiles
        activeProfileID = state.activeProfileID
        neverCloseApps = state.neverCloseApps
    }

    var activeProfile: Profile? {
        profiles.first { $0.id == activeProfileID }
    }

    private var protectedBundleIDs: Set<String> {
        Set(neverCloseApps.map(\.bundleIdentifier))
    }

    func activate(profile: Profile) async {
        let previous = profiles.first { $0.id == activeProfileID }
        await ProfileActivator.activate(profile, deactivating: previous, protectedBundleIDs: protectedBundleIDs)
        activeProfileID = profile.id
        persist()
    }

    func deactivateCurrent() {
        activeProfileID = nil
        persist()
    }

    func applyCloseListNow(_ profile: Profile) async {
        await AppTerminator.terminate(profile.closeApps, protectedBundleIDs: protectedBundleIDs)
    }

    @discardableResult
    func addProfile(named name: String = "New Profile") -> Profile {
        let profile = Profile(name: name)
        profiles.append(profile)
        persist()
        return profile
    }

    /// Creates a new profile whose open list is a snapshot of every
    /// user-visible app running right now (excluding always-protected
    /// system apps and Zwix itself).
    @discardableResult
    func addProfileFromSnapshot(named name: String = "Snapshot") -> Profile {
        let openApps = RunningAppsProvider.allUserVisibleApps()
            .compactMap { BundleInspector.entry(fromRunning: $0) }
            .filter { !AppTerminator.hardProtectedBundleIDs.contains($0.bundleIdentifier) }

        let profile = Profile(name: name, openApps: openApps)
        profiles.append(profile)
        persist()
        return profile
    }

    func updateProfile(_ profile: Profile) {
        guard let idx = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[idx] = profile
        persist()
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        if activeProfileID == profile.id {
            activeProfileID = nil
        }
        persist()
    }

    func isTriggerAppTaken(_ bundleIdentifier: String, excluding profileID: UUID?) -> Bool {
        profiles.contains { profile in
            profile.id != profileID && profile.triggerApps.contains { $0.bundleIdentifier == bundleIdentifier }
        }
    }

    func addNeverCloseApp(_ entry: AppEntry) {
        guard !neverCloseApps.contains(where: { $0.bundleIdentifier == entry.bundleIdentifier }) else { return }
        neverCloseApps.append(entry)
        persist()
    }

    func removeNeverCloseApp(_ entry: AppEntry) {
        neverCloseApps.removeAll { $0.bundleIdentifier == entry.bundleIdentifier }
        persist()
    }

    private func persist() {
        store.save(PersistedState(profiles: profiles, activeProfileID: activeProfileID, neverCloseApps: neverCloseApps))
    }
}
