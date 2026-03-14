import SwiftUI

struct PresetsView: View {
    @EnvironmentObject var presetsVM: PresetsViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var navigationState: AppNavigationState
    @State private var showingAddPreset = false
    @State private var presetToEdit: Preset?
    @State private var presetToDelete: Preset?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("WORKOUT")
                                    .aggressiveHeading(size: 32)
                                    .foregroundColor(.white)
                                Text("PRESETS")
                                    .aggressiveHeading(size: 32)
                                    .foregroundColor(.appOrange)
                            }

                            Spacer()

                            Button {
                                showingAddPreset = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("NEW")
                                        .font(.system(size: 12, weight: .black))
                                        .tracking(1)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 10, normalBackground: .appOrange, pressedBackground: .appOrange))
                        }
                        .padding(.top, 20)

                        if presetsVM.presets.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.3))

                                VStack(spacing: 8) {
                                    Text("No Presets Yet")
                                        .font(.title2.weight(.bold))
                                        .foregroundColor(.white)
                                    Text("Create your first workout preset\nto get started")
                                        .font(.subheadline)
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }

                                Button("CREATE PRESET") {
                                    showingAddPreset = true
                                }
                                .buttonStyle(.chunkyOrange)
                                .padding(.horizontal, 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(presetsVM.presets) { preset in
                                    PresetCard(
                                        preset: preset,
                                        onStart: {
                                            timerVM.loadPreset(preset)
                                            timerVM.start()
                                            navigationState.selectedTab = .timer
                                        },
                                        onEdit: {
                                            presetToEdit = preset
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
            .sheet(isPresented: $showingAddPreset) {
                PresetEditView(preset: nil, onSave: presetsVM.addPreset)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $presetToEdit) { preset in
                PresetEditView(preset: preset, onSave: presetsVM.updatePreset)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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
                    Text("\(preset.settings.totalSeconds / 60) min")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1)
                        .textCase(.uppercase)
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

                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                    Text(summaryText)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }

                Button {
                    onStart()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                        Text("Start Workout")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 10, normalBackground: .appOrange, pressedBackground: .appOrange))
                .padding(.top, 4)
            }
            .padding(20)
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var summaryText: String {
        let roundMinutes = preset.settings.roundDuration / 60
        let roundSeconds = preset.settings.roundDuration % 60
        let breakMinutes = preset.settings.breakDuration / 60
        let breakSeconds = preset.settings.breakDuration % 60

        let roundText = roundMinutes > 0 ? "\(roundMinutes)m\(roundSeconds > 0 ? " \(roundSeconds)s" : "")" : "\(roundSeconds)s"
        let breakText = breakMinutes > 0 ? "\(breakMinutes)m\(breakSeconds > 0 ? " \(breakSeconds)s" : "")" : "\(breakSeconds)s"

        return "\(preset.settings.numberOfRounds) Rounds • \(roundText) Work / \(breakText) Rest"
    }
}

#Preview {
    PresetsView()
        .environmentObject(PresetsViewModel())
        .environmentObject(TimerViewModel())
        .environmentObject(AppNavigationState())
}
