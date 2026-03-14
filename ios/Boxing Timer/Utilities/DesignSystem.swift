import SwiftUI

struct AggressiveHeading: ViewModifier {
    var size: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .black))
            .italic()
            .textCase(.uppercase)
            .tracking(-0.5)
    }
}

struct LabelStyle: ViewModifier {
    var size: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .heavy))
            .textCase(.uppercase)
            .tracking(2)
            .foregroundColor(.appTextSecondary)
    }
}

struct TimerDisplayStyle: ViewModifier {
    var size: CGFloat = 96

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .black, design: .monospaced))
            .tracking(-2)
            .foregroundColor(.white)
            .monospacedDigit()
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CardStyle: ViewModifier {
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

extension View {
    func aggressiveHeading(size: CGFloat = 24) -> some View {
        modifier(AggressiveHeading(size: size))
    }

    func labelUppercase(size: CGFloat = 10) -> some View {
        modifier(LabelStyle(size: size))
    }

    func timerDisplay(size: CGFloat = 96) -> some View {
        modifier(TimerDisplayStyle(size: size))
    }

    func cardStyle(padding: CGFloat = 20) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

struct ChunkyButtonStyle: ButtonStyle {
    enum Variant {
        case cyan, red, orange, ghost
    }

    let variant: Variant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .black))
            .italic()
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(backgroundColor)
            .cornerRadius(16)
    }

    private var backgroundColor: Color {
        switch variant {
        case .cyan: .appCyan
        case .red: .appRed
        case .orange: .appOrange
        case .ghost: Color.white.opacity(0.1)
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .cyan: Color(hex: "1C2A4A")
        case .red, .orange, .ghost: .white
        }
    }
}

extension ButtonStyle where Self == ChunkyButtonStyle {
    static var chunkyPrimary: ChunkyButtonStyle { ChunkyButtonStyle(variant: .cyan) }
    static var chunkyDanger: ChunkyButtonStyle { ChunkyButtonStyle(variant: .red) }
    static var chunkyOrange: ChunkyButtonStyle { ChunkyButtonStyle(variant: .orange) }
    static var chunkyGhost: ChunkyButtonStyle { ChunkyButtonStyle(variant: .ghost) }
}

struct TintedChunkyButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let pressedBackgroundColor: Color
    let foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .black))
            .italic()
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(backgroundColor)
            .cornerRadius(16)
    }
}

struct PressFeedbackButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 12
    var normalBackground: Color? = nil
    var pressedBackground: Color? = nil
    var normalForeground: Color? = nil
    var pressedForeground: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(normalForeground)
            .background(normalBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct IconBadge: View {
    let systemName: String
    var color: Color = .appCyan

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(color)
            .frame(width: 44, height: 44)
            .background(color.opacity(0.15))
            .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    var color: Color = .appCyan

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .textCase(.uppercase)
                .tracking(3)
                .foregroundColor(color)
        }
        .padding(.horizontal, 4)
    }
}
