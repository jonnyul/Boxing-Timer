import SwiftUI

struct SettingRow: View {
    enum ValueMode {
        case count(range: ClosedRange<Int>, step: Int = 1, suffix: String = "")
        case duration(min: Int = 5, max: Int = 600, step: Int = 5)
    }

    let icon: String
    let iconColor: Color
    let pressedIconColor: Color
    let title: String
    let mode: ValueMode
    @Binding var value: Int
    var onChange: () -> Void = {}
    var onEdit: (() -> Void)? = nil
    var onReset: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onReset?()
            } label: {
                IconBadge(
                    systemName: icon,
                    color: iconColor,
                    size: AppDesign.Control.iconSize + (AppDesign.Control.padding * 2),
                    iconSize: AppDesign.Control.iconSize
                )
            }
            .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: .clear, pressedBackground: .clear))

            Text(title)
                .rowTitle()
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Button {
                    onEdit?()
                } label: {
                    HStack(spacing: 6) {
                        Text(displayText)
                            .font(.system(size: AppDesign.Typography.controlValueSize, weight: .bold, design: .monospaced))
                            .foregroundColor(iconColor)
                            .fixedSize()
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(iconColor.opacity(onEdit == nil ? 0.35 : 0.8))
                    }
                    .padding(AppDesign.Control.padding)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: Color.white.opacity(0.04), pressedBackground: Color.white.opacity(0.04)))
                .disabled(onEdit == nil)

                Button {
                    guard canIncrement else { return }
                    value += step
                    onChange()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: AppDesign.Control.iconSize, weight: .bold))
                        .foregroundColor(canIncrement ? iconColor : iconColor.opacity(0.3))
                        .padding(AppDesign.Control.padding)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: Color.white.opacity(0.04), pressedBackground: Color.white.opacity(0.04)))

                Button {
                    guard canDecrement else { return }
                    value -= step
                    onChange()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: AppDesign.Control.iconSize, weight: .bold))
                        .foregroundColor(canDecrement ? iconColor : iconColor.opacity(0.3))
                        .padding(AppDesign.Control.padding)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: Color.white.opacity(0.04), pressedBackground: Color.white.opacity(0.04)))
            }
        }
        .cardStyle(padding: 16)
    }

    private var displayText: String {
        switch mode {
        case .count(_, _, let suffix): "\(value)\(suffix)"
        case .duration: value.mmss
        }
    }

    private var canDecrement: Bool {
        switch mode {
        case .count(let range, let step, _): value - step >= range.lowerBound
        case .duration(let min, _, let step): value - step >= min
        }
    }

    private var canIncrement: Bool {
        switch mode {
        case .count(let range, let step, _): value + step <= range.upperBound
        case .duration(_, let max, let step): value + step <= max
        }
    }

    private var step: Int {
        switch mode {
        case .count(_, let step, _), .duration(_, _, let step): step
        }
    }
}

#Preview {
    SettingRow(icon: "flame.fill", iconColor: .orange, pressedIconColor: .appOrangePressed, title: "Round Duration", mode: .duration(), value: .constant(180))
}
