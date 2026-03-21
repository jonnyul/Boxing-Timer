import SwiftUI

struct NumericSettingEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let icon: String
    let iconColor: Color
    let pressedIconColor: Color
    let mode: SettingRow.ValueMode
    @Binding var value: Int
    var onCommit: () -> Void = {}

    @State private var draftDigits: [Int]
    @State private var selectedIndex: Int
    @State private var invalidFlash = false
    @State private var shakeTrigger = 0

    // keypadButtonHeight = exactly half of SettingRow card height (76 / 2 = 38)
    // digitBoxHeight fills the digitDisplay card to match SettingRow height: 52 + 2*12 (cardStyle) = 76
    private let keypadButtonHeight: CGFloat = 44
    private let digitBoxHeight: CGFloat = 52
    private let digitBoxWidth: CGFloat = 42

    init(
        title: String,
        icon: String,
        iconColor: Color,
        pressedIconColor: Color,
        mode: SettingRow.ValueMode,
        value: Binding<Int>,
        onCommit: @escaping () -> Void = {}
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.pressedIconColor = pressedIconColor
        self.mode = mode
        self._value = value
        self.onCommit = onCommit

        let digits = Self.digits(for: value.wrappedValue, mode: mode)
        _draftDigits = State(initialValue: digits)
        _selectedIndex = State(initialValue: Swift.max(0, digits.count - 1))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                digitDisplay
                keypad
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.appBackgroundDeep.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                Button {
                    applyChanges()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: AppDesign.ActionButton.iconSize, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppDesign.Control.padding)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: iconColor, pressedBackground: pressedIconColor))
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(Color.appBackgroundDeep)
            }
        }
        .presentationDetents([.height(420)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.appBackgroundDeep)
    }

    private var instructionsText: String {
        switch mode {
        case .count:
            return "Tap a place value, type a number, or use backspace to zero that place."
        case .duration:
            return "Tap a minute or second digit, type a number, or use backspace to zero that place."
        }
    }

    private var digitDisplay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(Array(displayTokens.enumerated()), id: \.offset) { _, token in
                    switch token {
                    case .digit(let index, let digit):
                        Button {
                            selectedIndex = index
                        } label: {
                            Text("\(digit)")
                                .font(.system(size: 34, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: digitBoxWidth, height: digitBoxHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
                                        .stroke(borderColor(for: index), lineWidth: 2)
                                )
                        }
                        .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: backgroundColor(for: index)))
                    case .separator(let separator):
                        Text(separator)
                            .font(.system(size: 34, weight: .black, design: .monospaced))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .modifier(ShakeEffect(trigger: shakeTrigger))
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .cardStyle(padding: 12)
    }

    private var keypad: some View {
        VStack(spacing: 10) {
            ForEach(keypadRows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { item in
                        keypadButton(for: item)
                    }
                }
            }
        }
    }

    private func keypadButton(for item: KeypadItem) -> some View {
        Button {
            switch item {
            case .digit(let digit):
                setSelectedDigit(digit)
            case .backspace:
                zeroSelectedDigit()
            }
        } label: {
            ZStack {
                switch item {
                case .digit(let digit):
                    Text("\(digit)")
                        .font(.system(size: AppDesign.Control.iconSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                case .backspace:
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: AppDesign.Control.iconSize, weight: .bold))
                        .foregroundColor(.appRed)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppDesign.Control.padding)
            .frame(height: keypadButtonHeight)
        }
        .buttonStyle(
            NoFeedbackButtonStyle(
                cornerRadius: AppDesign.Radius.ten,
                backgroundColor: item == .backspace ? Color.appRed.opacity(0.2) : Color.white.opacity(0.08)
            )
        )
    }

    private var displayTokens: [DisplayToken] {
        switch mode {
        case .count:
            return draftDigits.enumerated().map { .digit(index: $0.offset, digit: $0.element) }
        case .duration:
            return [
                .digit(index: 0, digit: draftDigits[0]),
                .digit(index: 1, digit: draftDigits[1]),
                .separator(":"),
                .digit(index: 2, digit: draftDigits[2]),
                .digit(index: 3, digit: draftDigits[3])
            ]
        }
    }

    private var committedValue: Int {
        switch mode {
        case .count(let range, _, _):
            return clamp(countValue(from: draftDigits), range: range)
        case .duration(let minimum, let maximum, _):
            let minutes = (draftDigits[0] * 10) + draftDigits[1]
            let seconds = (draftDigits[2] * 10) + draftDigits[3]
            let rawValue = (minutes * 60) + seconds
            return Swift.min(Swift.max(rawValue, minimum), maximum)
        }
    }

    private var keypadRows: [[KeypadItem]] {
        [
            [.digit(1), .digit(2), .digit(3)],
            [.digit(4), .digit(5), .digit(6)],
            [.digit(7), .digit(8), .digit(9)],
            [.backspace, .digit(0)]
        ]
    }

    private func setSelectedDigit(_ digit: Int) {
        guard isDigitValid(digit, for: selectedIndex) else {
            triggerInvalidFeedback()
            return
        }

        var nextDigits = draftDigits
        nextDigits[selectedIndex] = digit

        guard isDraftValid(nextDigits) else {
            triggerInvalidFeedback()
            return
        }

        draftDigits = nextDigits

        if selectedIndex < draftDigits.count - 1 {
            selectedIndex += 1
        }
    }

    private func zeroSelectedDigit() {
        var nextDigits = draftDigits
        nextDigits[selectedIndex] = 0

        guard isDraftValid(nextDigits) else {
            triggerInvalidFeedback()
            return
        }

        draftDigits = nextDigits

        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }

    private func isDigitValid(_ digit: Int, for index: Int) -> Bool {
        switch mode {
        case .count:
            return true
        case .duration:
            return index != 2 || digit <= 5
        }
    }

    private func applyChanges() {
        value = committedValue
        onCommit()
        dismiss()
    }

    private func triggerInvalidFeedback() {
        withAnimation(.easeInOut(duration: 0.35)) {
            shakeTrigger += 1
        }
        withAnimation(.easeInOut(duration: 0.18)) {
            invalidFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.18)) {
                invalidFlash = false
            }
        }
    }

    private func isDraftValid(_ digits: [Int]) -> Bool {
        switch mode {
        case .count(let range, _, _):
            let rawValue = countValue(from: digits)
            return range.contains(rawValue)
        case .duration(let minimum, let maximum, _):
            let minutes = (digits[0] * 10) + digits[1]
            let seconds = (digits[2] * 10) + digits[3]
            let rawValue = (minutes * 60) + seconds
            return seconds < 60 && rawValue >= minimum && rawValue <= maximum
        }
    }

    private func backgroundColor(for index: Int) -> Color {
        if invalidFlash {
            return Color.appRed.opacity(index == selectedIndex ? 0.28 : 0.18)
        }

        return index == selectedIndex ? iconColor.opacity(0.24) : Color.white.opacity(0.08)
    }

    private func pressedBackgroundColor(for index: Int) -> Color {
        if invalidFlash {
            return Color.appRed.opacity(index == selectedIndex ? 0.45 : 0.35)
        }

        return backgroundColor(for: index)
    }

    private func borderColor(for index: Int) -> Color {
        if invalidFlash {
            return .appRed
        }

        return index == selectedIndex ? iconColor : Color.white.opacity(0.12)
    }

    private func countValue(from digits: [Int]) -> Int {
        digits.reduce(0) { ($0 * 10) + $1 }
    }

    private func clamp(_ value: Int, range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(value, range.lowerBound), range.upperBound)
    }

    private static func digits(for value: Int, mode: SettingRow.ValueMode) -> [Int] {
        switch mode {
        case .count(let range, _, _):
            let digitCount = String(range.upperBound).count
            let clamped = Swift.min(Swift.max(value, range.lowerBound), range.upperBound)
            return fixedDigits(for: clamped, count: digitCount)
        case .duration(let minimum, let maximum, _):
            let clamped = Swift.min(Swift.max(value, minimum), maximum)
            let minutes = clamped / 60
            let seconds = clamped % 60
            return [minutes / 10, minutes % 10, seconds / 10, seconds % 10]
        }
    }

    private static func fixedDigits(for value: Int, count: Int) -> [Int] {
        let stringValue = String(format: "%0\(count)d", value)
        return stringValue.compactMap { $0.wholeNumberValue }
    }
}

private struct ShakeEffect: GeometryEffect {
    var trigger: Int
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3

    var animatableData: CGFloat {
        get { CGFloat(trigger) }
        set { }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

private enum DisplayToken {
    case digit(index: Int, digit: Int)
    case separator(String)
}

private enum KeypadItem: Hashable {
    case digit(Int)
    case backspace
}

private struct NoFeedbackButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    NumericSettingEditorSheet(
        title: "Round Duration",
        icon: "flame.fill",
        iconColor: .orange,
        pressedIconColor: .appOrangePressed,
        mode: .duration(),
        value: .constant(180)
    )
}
