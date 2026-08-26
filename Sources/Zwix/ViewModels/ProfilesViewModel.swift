import AppKit
import Combine

@MainActor
final class ProfilesViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfileID: UUID?
    @Published var neverCloseApps: [AppEntry] = []
    @Published var terminationGracePeriod: TimeInterval = PersistedState.defaultTerminationGracePeriod
    @Published var confirmBeforeSwitch: Bool = false

    private let store = ProfileStore()

    init() {
        let state = store.load()
        profiles = state.profiles
        activeProfileID = state.activeProfileID
        neverCloseApps = state.neverCloseApps
        terminationGracePeriod = state.terminationGracePeriod
        confirmBeforeSwitch = state.confirmBeforeSwitch
    }

    var activeProfile: Profile? {
        profiles.first { $0.id == activeProfileID }
    }

    private var protectedBundleIDs: Set<String> {
        Set(neverCloseApps.map(\.bundleIdentifier))
    }

    func activate(profile: Profile) async {
        let previous = profiles.first { $0.id == activeProfileID }
        activeProfileID = profile.id
        persist()
        let summary = await ProfileActivator.activate(
            profile,
            deactivating: previous,
            protectedBundleIDs: protectedBundleIDs,
            gracePeriod: terminationGracePeriod
        )
        ToastNotifier.notifyActivation(profileName: profile.name, summary: summary)
    }

    func deactivateCurrent() {
        activeProfileID = nil
        persist()
    }

    /// Routes on the live activeProfileID at call time rather than a
    /// boolean captured by the view at its last render pass, so a click
    /// that lands before a SwiftUI redraw catches up still does the
    /// right thing.
    func toggleActivation(of profile: Profile) async {
        if activeProfileID == profile.id {
            deactivateCurrent()
        } else {
            await activate(profile: profile)
        }
    }

    func applyCloseListNow(_ profile: Profile) async {
        let result = await AppTerminator.terminate(profile.closeApps, protectedBundleIDs: protectedBundleIDs, gracePeriod: terminationGracePeriod)
        ToastNotifier.notifyFreedMemory(profileName: profile.name, result: result)
    }

    func setTerminationGracePeriod(_ seconds: TimeInterval) {
        terminationGracePeriod = seconds
        persist()
    }

    func setConfirmBeforeSwitch(_ enabled: Bool) {
        confirmBeforeSwitch = enabled
        persist()
    }

    func preview(for profile: Profile) -> ProfileActivator.Preview {
        let previous = profiles.first { $0.id == activeProfileID }
        return ProfileActivator.preview(profile, deactivating: previous, protectedBundleIDs: protectedBundleIDs)
    }

    @discardableResult
    func addProfile(named name: String = "New Profile") -> Profile {
        let profile = Profile(name: uniqueName(base: name))
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

        let profile = Profile(name: uniqueName(base: name), openApps: openApps)
        profiles.append(profile)
        persist()
        return profile
    }

    /// Appends " 2", " 3", etc. to `base` until it no longer collides with
    /// an existing profile's name. Leaves `base` unchanged if it's already
    /// unique.
    private func uniqueName(base: String) -> String {
        let existingNames = Set(profiles.map(\.name))
        guard existingNames.contains(base) else { return base }
        var suffix = 2
        while existingNames.contains("\(base) \(suffix)") {
            suffix += 1
        }
        return "\(base) \(suffix)"
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

    func exportData(for profile: Profile) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(profile)
    }

    /// Decodes a profile from exported JSON and adds it as a new profile.
    /// Assigns a fresh id (so importing on the same machine that exported
    /// it doesn't collide with the original) and a collision-free name.
    @discardableResult
    func importProfile(from data: Data) throws -> Profile {
        var profile = try JSONDecoder().decode(Profile.self, from: data)
        profile.id = UUID()
        profile.name = uniqueName(base: profile.name)
        profiles.append(profile)
        persist()
        return profile
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
        store.save(PersistedState(
            profiles: profiles,
            activeProfileID: activeProfileID,
            neverCloseApps: neverCloseApps,
            terminationGracePeriod: terminationGracePeriod,
            confirmBeforeSwitch: confirmBeforeSwitch
        ))
    }
}
