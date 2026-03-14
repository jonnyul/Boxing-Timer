import SwiftUI

struct PresetEditView: View {
    @Environment(\.dismiss) private var dismiss

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
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                Text("ROUND")
                                    .aggressiveHeading(size: 24)
                                    .foregroundColor(.appCyan)
                                Text("SETTINGS")
                                    .aggressiveHeading(size: 24)
                                    .foregroundColor(.white)
                            }

                            Spacer()
                        }
                        .padding(.top, 12)

                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "PRESET NAME")

                            TextField("Enter preset name", text: $name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        }

                        TimerSettingsEditor(
                            numberOfRounds: $numberOfRounds,
                            getReadyDuration: $getReadyDuration,
                            roundDuration: $roundDuration,
                            roundEndNotice: $roundEndNotice,
                            breakDuration: $breakDuration,
                            breakEndNotice: $breakEndNotice
                        )

                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appCyan)
                                Text("Total Workout:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                Text(totalWorkoutTime)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.appCyan)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.appCyan.opacity(0.1))
                            .cornerRadius(12)
                            Spacer()
                        }

                        Button("CONFIRM SETTINGS") {
                            savePreset()
                        }
                        .buttonStyle(.chunkyPrimary)
                        .disabled(trimmedName.isEmpty)
                        .opacity(trimmedName.isEmpty ? 0.5 : 1)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
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
    }
}

#Preview {
    PresetEditView(preset: nil, onSave: { _ in })
}
