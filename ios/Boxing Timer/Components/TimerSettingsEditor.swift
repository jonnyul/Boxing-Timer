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
        VStack(spacing: AppDesign.Layout.rowSpacing) {
            SettingRow(icon: "repeat", iconColor: .green, pressedIconColor: .appGreenPressed, title: "Round", mode: .count(range: 1...50), value: $numberOfRounds, onChange: onChange, onEdit: {
                activeEditor = .numberOfRounds
            }, onReset: {
                numberOfRounds = TimerSettings().numberOfRounds; onChange()
            })
            SettingRow(icon: "hourglass", iconColor: .yellow, pressedIconColor: .appYellowPressed, title: "Ready", mode: .duration(min: 1, max: 30, step: 1), value: $getReadyDuration, onChange: onChange, onEdit: {
                activeEditor = .getReadyDuration
            }, onReset: {
                getReadyDuration = TimerSettings().getReadyDuration; onChange()
            })
            SettingRow(icon: "flame.fill", iconColor: .orange, pressedIconColor: .appOrangePressed, title: "Round Length", mode: .duration(), value: $roundDuration, onChange: onChange, onEdit: {
                activeEditor = .roundDuration
            }, onReset: {
                roundDuration = TimerSettings().roundDuration; onChange()
            })
            SettingRow(icon: "bell.fill", iconColor: .yellow, pressedIconColor: .appYellowPressed, title: "Round End", mode: .duration(min: 0, max: 30, step: 1), value: $roundEndNotice, onChange: onChange, onEdit: {
                activeEditor = .roundEndNotice
            }, onReset: {
                roundEndNotice = TimerSettings().roundEndNotice; onChange()
            })
            SettingRow(icon: "pause.circle.fill", iconColor: .blue, pressedIconColor: .appBluePressed, title: "Break Length", mode: .duration(), value: $breakDuration, onChange: onChange, onEdit: {
                activeEditor = .breakDuration
            }, onReset: {
                breakDuration = TimerSettings().breakDuration; onChange()
            })
            SettingRow(icon: "bell.fill", iconColor: .cyan, pressedIconColor: .appCyanPressed, title: "Break End", mode: .duration(min: 0, max: 30, step: 1), value: $breakEndNotice, onChange: onChange, onEdit: {
                activeEditor = .breakEndNotice
            }, onReset: {
                breakEndNotice = TimerSettings().breakEndNotice; onChange()
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
                title: "Round",
                icon: "repeat",
                iconColor: .green,
                pressedIconColor: Color(hex: "6BDE78"),
                mode: .count(range: 1...50),
                value: $numberOfRounds,
                onCommit: onChange
            )
        case .getReadyDuration:
            NumericSettingEditorSheet(
                title: "Ready",
                icon: "hourglass",
                iconColor: .yellow,
                pressedIconColor: Color(hex: "FFD84D"),
                mode: .duration(min: 1, max: 30, step: 1),
                value: $getReadyDuration,
                onCommit: onChange
            )
        case .roundDuration:
            NumericSettingEditorSheet(
                title: "Round Length",
                icon: "flame.fill",
                iconColor: .orange,
                pressedIconColor: .appOrangePressed,
                mode: .duration(),
                value: $roundDuration,
                onCommit: onChange
            )
        case .roundEndNotice:
            NumericSettingEditorSheet(
                title: "Round End",
                icon: "bell.fill",
                iconColor: .yellow,
                pressedIconColor: Color(hex: "FFD84D"),
                mode: .duration(min: 0, max: 30, step: 1),
                value: $roundEndNotice,
                onCommit: onChange
            )
        case .breakDuration:
            NumericSettingEditorSheet(
                title: "Break Length",
                icon: "pause.circle.fill",
                iconColor: .blue,
                pressedIconColor: Color(hex: "5DA9FF"),
                mode: .duration(),
                value: $breakDuration,
                onCommit: onChange
            )
        case .breakEndNotice:
            NumericSettingEditorSheet(
                title: "Break End",
                icon: "bell.fill",
                iconColor: .cyan,
                pressedIconColor: Color(hex: "63F7FF"),
                mode: .duration(min: 0, max: 30, step: 1),
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
