import SwiftUI

struct PresetsView: View {
    @EnvironmentObject var presetsVM: PresetsViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var navigationState: AppNavigationState
    @State private var presetToDelete: Preset?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack(path: $navigationState.presetsPath) {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 12) {
                        HStack {
                            Text("PRESETS")
                                .aggressiveHeading(size: 32)
                                .foregroundColor(.appOrange)

                            Spacer()

                            Button {
                                navigationState.presetsNewPresetSettings = nil
                                navigationState.presetsReturnTab = .presets
                                navigationState.presetsPath = [.add]
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
                        }
                        .padding(.top, 20)

                        if !presetsVM.presets.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(presetsVM.presets) { preset in
                                    PresetCard(
                                        preset: preset,
                                        onStart: {
                                            timerVM.loadPreset(preset)
                                            timerVM.start()
                                            navigationState.selectedTab = .timer
                                        },
                                        onEdit: {
                                            navigationState.presetsReturnTab = .presets
                                            navigationState.presetsPath = [.edit(preset.id)]
                                        },
                                        onDelete: {
                                            presetToDelete = preset
                                            showingDeleteConfirmation = true
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: PresetsDestination.self) { destination in
                switch destination {
                case .add:
                    PresetEditView(
                        preset: nil,
                        initialSettings: navigationState.presetsNewPresetSettings,
                        onSave: presetsVM.addPreset
                    )
                case .edit(let id):
                    if let preset = presetsVM.presets.first(where: { $0.id == id }) {
                        PresetEditView(preset: preset, onSave: presetsVM.updatePreset)
                    }
                }
            }
            .alert("Delete Preset?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    presetToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let presetToDelete {
                        presetsVM.deletePreset(id: presetToDelete.id)
                    }
                    presetToDelete = nil
                }
            } message: {
                if let presetToDelete {
                    Text("Are you sure you want to delete \"\(presetToDelete.name)\"? This action cannot be undone.")
                }
            }
        }
    }
}

struct PresetCard: View {
    let preset: Preset
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11, weight: .heavy))
                        Text(preset.settings.totalSeconds.mmss)
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                    }
                    .foregroundColor(.appOrange)

                    Spacer()

                    Menu {
                        Button("Edit", systemImage: "pencil", action: onEdit)
                        Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 10, normalBackground: .clear, pressedBackground: .clear, normalForeground: .white.opacity(0.5), pressedForeground: .white.opacity(0.5)))
                }

                Text(preset.name)
                    .font(.system(size: 20, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(.green)
                        Text("\(preset.settings.numberOfRounds) ROUNDS")
                            .labelUppercase(size: 8)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(.orange)
                        Text(preset.settings.roundDuration.mmss)
                            .labelUppercase(size: 8)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(.blue)
                        Text(preset.settings.breakDuration.mmss)
                            .labelUppercase(size: 8)
                    }
                }

                Button {
                    onStart()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppDesign.ActionButton.height)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.ActionButton.radius, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
            }
            .padding(AppDesign.Spacing.lg)
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

}

#Preview {
    PresetsView()
        .environmentObject(PresetsViewModel())
        .environmentObject(TimerViewModel())
        .environmentObject(AppNavigationState())
}
