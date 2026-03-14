import SwiftUI

struct TimerSettingsEditor: View {
    enum EditableSetting: String, Identifiable {
        case numberOfRounds
        case getReadyDuration
        case roundDuration
        case roundEndNotice
        case breakDuration
        case breakEndNotice

        var id: String { rawValue }
    }

    @Binding var numberOfRounds: Int
    @Binding var getReadyDuration: Int
    @Binding var roundDuration: Int
    @Binding var roundEndNotice: Int
    @Binding var breakDuration: Int
    @Binding var breakEndNotice: Int
    var onChange: () -> Void = {}

    @State private var activeEditor: EditableSetting?

    var body: some View {
        VStack(spacing: 12) {
            SettingRow(icon: "repeat", iconColor: .green, pressedIconColor: .appGreenPressed, title: "Number of Rounds", mode: .count(range: 1...50), value: $numberOfRounds, onChange: onChange, onEdit: {
                activeEditor = .numberOfRounds
            })
            SettingRow(icon: "hourglass", iconColor: .yellow, pressedIconColor: .appYellowPressed, title: "Get Ready", mode: .count(range: 1...30, suffix: "s"), value: $getReadyDuration, onChange: onChange, onEdit: {
                activeEditor = .getReadyDuration
            })
            SettingRow(icon: "flame.fill", iconColor: .orange, pressedIconColor: .appOrangePressed, title: "Round Duration", mode: .duration(), value: $roundDuration, onChange: onChange, onEdit: {
                activeEditor = .roundDuration
            })
            SettingRow(icon: "bell.fill", iconColor: .yellow, pressedIconColor: .appYellowPressed, title: "Round End Notice", mode: .count(range: 0...30, suffix: "s"), value: $roundEndNotice, onChange: onChange, onEdit: {
                activeEditor = .roundEndNotice
            })
            SettingRow(icon: "pause.circle.fill", iconColor: .blue, pressedIconColor: .appBluePressed, title: "Break Duration", mode: .duration(), value: $breakDuration, onChange: onChange, onEdit: {
                activeEditor = .breakDuration
            })
            SettingRow(icon: "bell.fill", iconColor: .cyan, pressedIconColor: .appCyanPressed, title: "Break End Notice", mode: .count(range: 0...30, suffix: "s"), value: $breakEndNotice, onChange: onChange, onEdit: {
                activeEditor = .breakEndNotice
            })
        }
        .sheet(item: $activeEditor) { editor in
            editorSheet(for: editor)
        }
    }

    @ViewBuilder
    private func editorSheet(for editor: EditableSetting) -> some View {
        switch editor {
        case .numberOfRounds:
            NumericSettingEditorSheet(
                title: "Number of Rounds",
                icon: "repeat",
                iconColor: .green,
                pressedIconColor: Color(hex: "6BDE78"),
                mode: .count(range: 1...50),
                value: $numberOfRounds,
                onCommit: onChange
            )
        case .getReadyDuration:
            NumericSettingEditorSheet(
                title: "Get Ready",
                icon: "hourglass",
                iconColor: .yellow,
                pressedIconColor: Color(hex: "FFD84D"),
                mode: .count(range: 1...30, suffix: "s"),
                value: $getReadyDuration,
                onCommit: onChange
            )
        case .roundDuration:
            NumericSettingEditorSheet(
                title: "Round Duration",
                icon: "flame.fill",
                iconColor: .orange,
                pressedIconColor: .appOrangePressed,
                mode: .duration(),
                value: $roundDuration,
                onCommit: onChange
            )
        case .roundEndNotice:
            NumericSettingEditorSheet(
                title: "Round End Notice",
                icon: "bell.fill",
                iconColor: .yellow,
                pressedIconColor: Color(hex: "FFD84D"),
                mode: .count(range: 0...30, suffix: "s"),
                value: $roundEndNotice,
                onCommit: onChange
            )
        case .breakDuration:
            NumericSettingEditorSheet(
                title: "Break Duration",
                icon: "pause.circle.fill",
                iconColor: .blue,
                pressedIconColor: Color(hex: "5DA9FF"),
                mode: .duration(),
                value: $breakDuration,
                onCommit: onChange
            )
        case .breakEndNotice:
            NumericSettingEditorSheet(
                title: "Break End Notice",
                icon: "bell.fill",
                iconColor: .cyan,
                pressedIconColor: Color(hex: "63F7FF"),
                mode: .count(range: 0...30, suffix: "s"),
                value: $breakEndNotice,
                onCommit: onChange
            )
        }
    }
}

#Preview {
    TimerSettingsEditor(
        numberOfRounds: .constant(5),
        getReadyDuration: .constant(10),
        roundDuration: .constant(180),
        roundEndNotice: .constant(10),
        breakDuration: .constant(60),
        breakEndNotice: .constant(10)
    )
}
