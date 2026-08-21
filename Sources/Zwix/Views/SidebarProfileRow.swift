import SwiftUI

struct SidebarProfileRow: View {
    let profile: Profile

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: profile.iconName)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(profile.name.isEmpty ? "Untitled" : profile.name)
                Text("\(profile.openApps.count) open · \(profile.closeApps.count) close" + (profile.triggerApps.isEmpty ? "" : " · \(profile.triggerApps.count) trigger\(profile.triggerApps.count == 1 ? "" : "s")"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
