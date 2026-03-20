import SwiftUI

struct PresetEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationState: AppNavigationState

    let preset: Preset?
    let initialSettings: TimerSettings?
    let onSave: (Preset) -> Void

    @State private var name: String
    @State private var numberOfRounds: Int
    @State private var roundDuration: Int
    @State private var breakDuration: Int
    @State private var roundEndNotice: Int
    @State private var breakEndNotice: Int
    @State private var getReadyDuration: Int
    @State private var bellsType: Int

    init(
        preset: Preset?,
        initialSettings: TimerSettings? = nil,
        onSave: @escaping (Preset) -> Void
    ) {
        self.preset = preset
        self.initialSettings = initialSettings
        self.onSave = onSave

        let sourceSettings = preset?.settings ?? initialSettings ?? TimerSettings()

        _name = State(initialValue: preset?.name ?? "")
        _numberOfRounds = State(initialValue: sourceSettings.numberOfRounds)
        _roundDuration = State(initialValue: sourceSettings.roundDuration)
        _breakDuration = State(initialValue: sourceSettings.breakDuration)
        _roundEndNotice = State(initialValue: sourceSettings.roundEndNotice)
        _breakEndNotice = State(initialValue: sourceSettings.breakEndNotice)
        _getReadyDuration = State(initialValue: sourceSettings.getReadyDuration)
        _bellsType = State(initialValue: sourceSettings.bellsType)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button {
                            dismiss()
                            if navigationState.presetsReturnTab != .presets {
                                navigationState.selectedTab = navigationState.presetsReturnTab
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: Color.white.opacity(0.08), pressedBackground: Color.white.opacity(0.15)))

                        Text("PRESETS").foregroundColor(.appOrange)
                            .aggressiveHeading(size: 32)

                        Spacer()
                    }

                    TextField("Enter preset name", text: $name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        TimerSettingsEditor(
                            numberOfRounds: $numberOfRounds,
                            getReadyDuration: $getReadyDuration,
                            roundDuration: $roundDuration,
                            roundEndNotice: $roundEndNotice,
                            breakDuration: $breakDuration,
                            breakEndNotice: $breakEndNotice
                        )

                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: AppDesign.WorkoutInfo.iconSize))
                                    .foregroundColor(.white)
                                Text(totalWorkoutTime)
                                    .font(.system(size: AppDesign.WorkoutInfo.fontSize, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppDesign.ActionButton.height)
                            .background(AppDesign.WorkoutInfo.background)
                            .cornerRadius(AppDesign.ActionButton.radius)

                            Button {
                                savePreset()
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                            .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
                            .disabled(trimmedName.isEmpty)
                            .opacity(trimmedName.isEmpty ? 0.5 : 1)
                        }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var totalWorkoutTime: String {
        (getReadyDuration + (numberOfRounds * roundDuration) + (max(0, numberOfRounds - 1) * breakDuration)).mmss
    }

    private func savePreset() {
        var newPreset = Preset(
            name: trimmedName,
            settings: TimerSettings(
                numberOfRounds: numberOfRounds,
                roundDuration: max(1, roundDuration),
                breakDuration: max(1, breakDuration),
                roundEndNotice: roundEndNotice,
                breakEndNotice: breakEndNotice,
                getReadyDuration: getReadyDuration,
                bellsType: bellsType
            )
        )

        if let preset {
            newPreset.id = preset.id
        }

        onSave(newPreset)
        dismiss()
        if navigationState.presetsReturnTab != .presets {
            navigationState.selectedTab = navigationState.presetsReturnTab
        }
    }
}

#Preview {
    PresetEditView(preset: nil, onSave: { _ in })
}
