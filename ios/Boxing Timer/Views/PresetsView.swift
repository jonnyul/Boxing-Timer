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
                    VStack(spacing: AppDesign.Layout.rowSpacing) {
                        HStack(alignment: .bottom) {
                            Text("PRESETS")
                                .aggressiveHeading(size: AppDesign.Typography.pageTitleSize)
                                .foregroundColor(.appOrange)
                                .lineLimit(1)
                                .minimumScaleFactor(0.3)
                                .padding(.bottom, AppDesign.Layout.titleBottomTrim)

                            Spacer(minLength: 0)

                            Button {
                                navigationState.presetsNewPresetSettings = nil
                                navigationState.presetsReturnTab = .presets
                                navigationState.presetsPath = [.add]
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 23, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(AppDesign.Control.padding)
                            }
                            .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
                        }
                        .padding(.top, 20)

                        if !presetsVM.presets.isEmpty {
                            VStack(spacing: AppDesign.Layout.rowSpacing) {
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
            VStack(alignment: .leading, spacing: AppDesign.Layout.rowSpacing) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: AppDesign.WorkoutInfo.iconSize))
                        Text(preset.settings.totalSeconds.mmss)
                            .font(.system(size: AppDesign.WorkoutInfo.fontSize, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(AppDesign.Control.padding)
                    .background(AppDesign.WorkoutInfo.background)
                    .cornerRadius(AppDesign.Radius.ten)

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
                    .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: .clear, pressedBackground: .clear, normalForeground: .white.opacity(0.5), pressedForeground: .white.opacity(0.5)))
                }

                Text(preset.name)
                    .cardTitle()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    presetStatCard(icon: "repeat", color: .green, value: "\(preset.settings.numberOfRounds)")
                    presetStatCard(icon: "flame.fill", color: .orange, value: preset.settings.roundDuration.mmss)
                    presetStatCard(icon: "pause.fill", color: .blue, value: preset.settings.breakDuration.mmss)
                }

                Button {
                    onStart()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: AppDesign.ActionButton.iconSize, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppDesign.Control.padding)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
            }
            .padding(AppDesign.Spacing.lg)
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(AppDesign.Radius.ten)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func presetStatCard(icon: String, color: Color, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: AppDesign.Typography.controlValueSize, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(AppDesign.Control.padding)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(AppDesign.Radius.ten)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
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
