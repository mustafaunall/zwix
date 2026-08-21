import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @EnvironmentObject var viewModel: ProfilesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Zwix").font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 6)

            Divider()

            VStack(spacing: 0) {
                if viewModel.profiles.isEmpty {
                    Text("No profiles yet — add one in Settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(12)
                } else {
                    ForEach(viewModel.profiles) { profile in
                        let isActive = viewModel.activeProfileID == profile.id
                        MenuRow(isActive: isActive) {
                            Task {
                                if isActive {
                                    viewModel.deactivateCurrent()
                                } else {
                                    await viewModel.activate(profile: profile)
                                }
                            }
                        } icon: {
                            ZStack(alignment: .bottomTrailing) {
                                Image(systemName: profile.iconName)
                                    .font(.system(size: 14))
                                    .foregroundColor(isActive ? .accentColor : .secondary)
                                if isActive {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(.accentColor)
                                        .background(Circle().fill(Color(nsColor: .windowBackgroundColor)))
                                        .offset(x: 3, y: 3)
                                }
                            }
                        } label: {
                            Text(profile.name)
                                .fontWeight(isActive ? .semibold : .regular)
                        }
                    }
                }
            }
            .padding(.vertical, 4)

            Divider()

            MenuRow(isActive: false) {
                MenuBarPopoverController.shared.close()
                SettingsWindowController.shared.show(viewModel: viewModel)
            } icon: {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } label: {
                Text("Settings…")
            }

            MenuRow(isActive: false) {
                NSApp.terminate(nil)
            } icon: {
                Image(systemName: "power")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } label: {
                Text("Quit Zwix")
            }
            .padding(.bottom, 6)
        }
        .frame(width: 260)
    }
}

private struct MenuRow<Icon: View, Label: View>: View {
    let isActive: Bool
    let action: () -> Void
    @ViewBuilder let icon: Icon
    @ViewBuilder let label: Label

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon.frame(width: 18, alignment: .center)
                label
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
        )
        .padding(.horizontal, 6)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.1), value: isHovering)
    }
}
