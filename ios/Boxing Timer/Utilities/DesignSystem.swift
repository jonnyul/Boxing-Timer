import SwiftUI

// MARK: - Design Tokens
// Single source of truth for all visual constants in the app.
// When adding a new feature, pull values from here instead of hardcoding.
enum AppDesign {

    // MARK: Corner Radii
    enum Radius {
        static let card: CGFloat = 16        // cards, sheet containers, chunky buttons
        static let badge: CGFloat = 12       // icon badges, text fields, input rows
        static let button: CGFloat = 10      // compact inline buttons (value box, +/-)
        static let pill: CGFloat = 999       // fully-rounded pills (use on any height)
        static let heatmap: CGFloat = 3      // contribution graph squares + legend swatches
    }

    // MARK: Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16          // default screen / card padding
        static let xl: CGFloat = 20          // section padding, screen insets
        static let xxl: CGFloat = 24
    }

    // MARK: Card Surface
    // Use .cardStyle(padding:) modifier for standard cards.
    enum Card {
        static let background = Color.white.opacity(0.05)
        static let border = Color.white.opacity(0.08)
        static let borderWidth: CGFloat = 1
        static let radius: CGFloat = Radius.card
    }

    // MARK: Icon Badge
    // Use IconBadge(systemName:color:) for consistency.
    enum Badge {
        static let size: CGFloat = 44
        static let iconSize: CGFloat = 16
        static let backgroundOpacity: Double = 0.15
        static let radius: CGFloat = Radius.badge
    }

    // MARK: Controls (inline buttons inside setting rows)
    enum Control {
        static let height: CGFloat = 44      // value box, +/- buttons, icon badge
        static let radius: CGFloat = Radius.button
        static let background = Color.white.opacity(0.04)
    }

    // MARK: Action Buttons (full-width icon buttons: play, reset, plus, checkmark, back)
    // These are the standalone icon-only buttons used at the bottom of screens.
    enum ActionButton {
        static let height: CGFloat = 44       // matches Control.height
        static let radius: CGFloat = Radius.badge  // 12pt
    }

    // MARK: Workout Info Block (total workout time display — home header + preset editor)
    enum WorkoutInfo {
        static let height: CGFloat = ActionButton.height
        static let radius: CGFloat = ActionButton.radius
        static let iconSize: CGFloat = 14
        static let fontSize: CGFloat = 18
        static let background = Color(hex: "5DA9FF").opacity(0.15)
    }

    // MARK: Semantic Icons
    // These SF Symbol names are used consistently across all screens.
    // Always pair the icon with its matching color so they read the same everywhere.
    enum Icons {
        // Timer settings rectangles (SettingRow) + preset card stats + TimerView info cards
        static let rounds    = "repeat"           // color: .green
        static let work      = "flame.fill"       // color: .orange   (round duration)
        static let rest      = "pause.fill"       // color: .blue     (break duration)
        static let getReady  = "hourglass"        // color: .yellow
        static let roundEnd  = "bell.fill"        // color: .yellow   (round end notice)
        static let breakEnd  = "bell.fill"        // color: .cyan     (break end notice)
        static let time      = "clock.fill"       // color: .appOrange (total workout time)

        // Actions
        static let play      = "play.fill"        // color: navy (on cyan bg) or white
        static let plus      = "plus"             // color: white (on orange bg)
        static let reset     = "arrow.2.circlepath" // color: white (on ghost bg)
        static let confirm   = "checkmark"        // color: white (on orange bg)
        static let back      = "chevron.left"     // color: white (on ghost bg)
    }

    // MARK: Typography (reference — use the .aggressiveHeading / .labelUppercase / .timerDisplay modifiers)
    // Screen titles:  .aggressiveHeading(size: 32–48), two-color via Text concatenation
    // Section labels: .labelUppercase(size: 10)
    // Card body:      .system(size: 15, weight: .semibold), white, italic for setting row labels
    // Value readout:  .system(size: 20, weight: .bold, design: .monospaced), iconColor
    // Timer display:  .timerDisplay(size: 96)

    // MARK: Screen Layout
    enum Layout {
        static let horizontalPadding: CGFloat = Spacing.lg   // padding(.horizontal) on scroll content
        static let topPadding: CGFloat = Spacing.xl          // padding from safe-area top to first element
        static let sectionSpacing: CGFloat = Spacing.md      // VStack spacing between major sections
        static let rowSpacing: CGFloat = Spacing.md          // spacing between list rows (e.g. SettingRows)
    }
}

// MARK: - View Modifiers

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
    var size: CGFloat = 44
    var iconSize: CGFloat? = nil

    var body: some View {
        let resolvedIconSize = iconSize ?? (size * 16 / 44)
        Image(systemName: systemName)
            .font(.system(size: resolvedIconSize, weight: .semibold))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.15))
            .cornerRadius(size * 12 / 44)
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
