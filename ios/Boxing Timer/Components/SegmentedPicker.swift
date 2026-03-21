import SwiftUI

struct SegmentedPicker<T: Hashable>: View {
    @Binding var selection: T
    let options: [T]
    let labels: [T: String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option
                    }
                } label: {
                    Text(labels[option] ?? "\(option)")
                        .font(.system(size: 13, weight: selection == option ? .bold : .medium))
                        .foregroundColor(selection == option ? .appBackgroundDeep : .appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(
                    PressFeedbackButtonStyle(
                        cornerRadius: AppDesign.Radius.ten,
                        normalBackground: selection == option ? .appCyan : .clear,
                        pressedBackground: selection == option ? .appCyan : .clear,
                        normalForeground: selection == option ? .appBackgroundDeep : .appTextSecondary,
                        pressedForeground: selection == option ? .appBackgroundDeep : .appTextSecondary
                    )
                )
            }
        }
        .padding(4)
        .background(Color.appBackgroundDeep)
        .cornerRadius(AppDesign.Radius.ten)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
