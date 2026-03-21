import SwiftUI

// MARK: - Design Tokens
// Single source of truth for all visual constants in the app.
// When adding a new feature, pull values from here instead of hardcoding.
enum AppDesign {

    // MARK: Corner Radius
    enum Radius {
        static let three: CGFloat = 3
        static let ten: CGFloat = 10
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
    }

    // MARK: Icon Badge
    // Use IconBadge(systemName:color:) for consistency.
    enum Badge {
        static let size: CGFloat = 44
        static let iconSize: CGFloat = 16
        static let backgroundOpacity: Double = 0.15
    }

    // MARK: Controls (inline buttons inside setting rows)
    enum Control {
        static let height: CGFloat = 44      // kept for reference; prefer padding-based sizing
        static let background = Color.white.opacity(0.04)
        static let padding: CGFloat = 8      // uniform padding all sides — use instead of frame(height:44)
        static let iconSize: CGFloat = Typography.controlValueSize
    }

    // MARK: Action Buttons (full-width icon buttons: play, reset, plus, checkmark, back)
    // These are the standalone icon-only buttons used at the bottom of screens.
    enum ActionButton {
        static let height: CGFloat = 44       // matches Control.height
        static let iconSize: CGFloat = Typography.controlValueSize
    }

    // MARK: Workout Info Block (total workout time display — home header + preset editor)
    enum WorkoutInfo {
        static let height: CGFloat = ActionButton.height
        static let iconSize: CGFloat = 14
        static let fontSize: CGFloat = Typography.controlValueSize
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

    // MARK: Typography
    // Scale doubles at each level — use AppDesign.Typography constants everywhere.
    // NOTE: minimumScaleFactor must be applied directly on Text, not inside a ViewModifier.
    enum Typography {
        static let rowTitleSize: CGFloat     = 15    // base: timer-page text, privacy policy, setting row labels
        static let controlValueSize: CGFloat = 20    // value readout in SettingRow controls and preset stat cards
        static let cardTitleSize: CGFloat  = 30    // preset card name (2× base)
        static let statNumberSize: CGFloat = 38    // stats summary numbers (1.25× card title)
        static let pageTitleSize: CGFloat  = 48    // TIMER / PRESETS / STATS / SETTINGS headings (1.25× stat)
    }

    // MARK: Screen Layout
    enum Layout {
        static let horizontalPadding: CGFloat = Spacing.lg   // padding(.horizontal) on scroll content
        static let topPadding: CGFloat = Spacing.xl          // padding from safe-area top to first element
        static let sectionSpacing: CGFloat = Spacing.md      // VStack spacing between major sections
        static let rowSpacing: CGFloat = Spacing.md          // spacing between list rows (e.g. SettingRows)
        static let titleBottomTrim: CGFloat = -10            // trims large heading line-box gap under page titles
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

struct RowTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: AppDesign.Typography.rowTitleSize, weight: .semibold))
            .italic()
            .textCase(.uppercase)
    }
}

struct CardTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: AppDesign.Typography.cardTitleSize, weight: .semibold))
            .textCase(.uppercase)
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
            .cornerRadius(AppDesign.Radius.ten)
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
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

    func rowTitle() -> some View {
        modifier(RowTitleStyle())
    }

    func cardTitle() -> some View {
        modifier(CardTitleStyle())
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
            .cornerRadius(AppDesign.Radius.ten)
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
            .cornerRadius(AppDesign.Radius.ten)
    }
}

struct PressFeedbackButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = AppDesign.Radius.ten
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
            .cornerRadius(AppDesign.Radius.ten)
    }
}

// Shared info card used on the timer screen and preset cards — icon badge, monospaced value, uppercase label.
struct TimerInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 6) {
            IconBadge(systemName: icon, color: iconColor)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .labelUppercase(size: 8)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(AppDesign.Radius.ten)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
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
