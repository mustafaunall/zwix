import SwiftUI

struct IconPickerGrid: View {
    @Binding var selection: String

    private let columns = [GridItem(.adaptive(minimum: 34), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(ProfileIcons.all, id: \.self) { icon in
                Button {
                    selection = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle().fill(selection == icon ? Color.accentColor : Color.primary.opacity(0.08))
                        )
                        .foregroundColor(selection == icon ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
