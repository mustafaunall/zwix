import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var viewModel: ProfilesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var gracePeriod: Double

    init() {
        _gracePeriod = State(initialValue: 2.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("General", systemImage: "slider.horizontal.3")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Force-quit grace period").font(.subheadline.weight(.semibold))
                Text("How long Zwix waits for an app to quit on its own before force-terminating it.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    Slider(value: $gracePeriod, in: 0.5...10, step: 0.5) {
                        Text("Grace period")
                    }
                    Text("\(gracePeriod, specifier: "%.1f")s")
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 340, height: 220)
        .onAppear {
            gracePeriod = viewModel.terminationGracePeriod
        }
        .onChange(of: gracePeriod) { newValue in
            viewModel.setTerminationGracePeriod(newValue)
        }
    }
}
