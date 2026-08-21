import AppKit
import Combine

@MainActor
final class ProfilesViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfileID: UUID?

    private let store = ProfileStore()

    init() {
        let state = store.load()
        profiles = state.profiles
        activeProfileID = state.activeProfileID
    }

    var activeProfile: Profile? {
        profiles.first { $0.id == activeProfileID }
    }

    func activate(profile: Profile) async {
        let previous = profiles.first { $0.id == activeProfileID }
        await ProfileActivator.activate(profile, deactivating: previous)
        activeProfileID = profile.id
        persist()
    }

    func deactivateCurrent() {
        activeProfileID = nil
        persist()
    }

    func applyCloseListNow(_ profile: Profile) async {
        await AppTerminator.terminate(profile.closeApps)
    }

    @discardableResult
    func addProfile(named name: String = "New Profile") -> Profile {
        let profile = Profile(name: name)
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
        profiles.contains {
            $0.id != profileID && $0.triggerApp?.bundleIdentifier == bundleIdentifier
        }
    }

    private func persist() {
        store.save(PersistedState(profiles: profiles, activeProfileID: activeProfileID))
    }
}
