import SwiftUI

struct HomeView: View {
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var presetsVM: PresetsViewModel
    @State private var showingSavePreset = false

    private var isRunning: Bool {
        timerVM.phase != .idle && timerVM.phase != .done
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if isRunning {
                    TimerView()
                        .environmentObject(timerVM)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(spacing: 24) {
                                Spacer()
                                VStack(spacing: 4) {
                                    Text("BOXING")
                                        .aggressiveHeading(size: 48)
                                        .foregroundColor(.white)
                                    Text("TIMER")
                                        .aggressiveHeading(size: 48)
                                        .foregroundColor(.appCyan)
                                }

                                TimerSettingsEditor(
                                    numberOfRounds: $timerVM.settings.numberOfRounds,
                                    getReadyDuration: $timerVM.settings.getReadyDuration,
                                    roundDuration: $timerVM.settings.roundDuration,
                                    roundEndNotice: $timerVM.settings.roundEndNotice,
                                    breakDuration: $timerVM.settings.breakDuration,
                                    breakEndNotice: $timerVM.settings.breakEndNotice
                                ) {
                                    timerVM.updateSettings(timerVM.settings)
                                }

                                HStack {
                                    Spacer()
                                    Button {
                                        showingSavePreset = true
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 14, weight: .bold))
                                            Text("Save as Preset")
                                                .font(.system(size: 14, weight: .black))
                                                .italic()
                                                .textCase(.uppercase)
                                                .tracking(1)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
                                    Spacer()
                                }

                                Button {
                                    timerVM.start()
                                } label: {
                                    Text("START ROUND")
                                }
                                .buttonStyle(.chunkyPrimary)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSavePreset) {
                PresetEditView(
                    preset: nil,
                    initialSettings: timerVM.settings,
                    onSave: presetsVM.addPreset
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(TimerViewModel())
        .environmentObject(PresetsViewModel())
}
