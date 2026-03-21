import SwiftUI

struct HomeView: View {
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var presetsVM: PresetsViewModel
    @EnvironmentObject var navigationState: AppNavigationState

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
                        VStack(spacing: AppDesign.Layout.rowSpacing) {
                            HStack(spacing: 12) {
                                Text("TIMER").foregroundColor(.appCyan)
                                    .aggressiveHeading(size: AppDesign.Typography.pageTitleSize)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.3)
                                    .padding(.bottom, AppDesign.Layout.titleBottomTrim)

                                Spacer()

                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: AppDesign.WorkoutInfo.iconSize))
                                    Text(timerVM.settings.totalSeconds.mmss)
                                        .font(.system(size: AppDesign.WorkoutInfo.fontSize, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(.white)
                                .padding(AppDesign.Control.padding)
                                .background(AppDesign.WorkoutInfo.background)
                                .cornerRadius(AppDesign.Radius.ten)
                                .padding(.bottom, AppDesign.Layout.titleBottomTrim)
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

                            HStack(spacing: 12) {
                                Button {
                                    timerVM.start()
                                } label: {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: AppDesign.ActionButton.iconSize, weight: .bold))
                                        .foregroundColor(Color(hex: "1C2A4A"))
                                        .frame(maxWidth: .infinity)
                                        .padding(AppDesign.Control.padding)
                                }
                                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: .appCyan, pressedBackground: .appCyanPressed))

                                Button {
                                    timerVM.updateSettings(TimerSettings())
                                } label: {
                                    Image(systemName: "arrow.2.circlepath")
                                        .font(.system(size: AppDesign.ActionButton.iconSize, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(AppDesign.Control.padding)
                                }
                                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: Color.white.opacity(0.08), pressedBackground: Color.white.opacity(0.15)))

                                Button {
                                    navigationState.presetsNewPresetSettings = timerVM.settings
                                    navigationState.presetsReturnTab = .timer
                                    navigationState.presetsPath = [.add]
                                    navigationState.selectedTab = .presets
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 23, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(AppDesign.Control.padding)
                                }
                                .buttonStyle(PressFeedbackButtonStyle(cornerRadius: AppDesign.Radius.ten, normalBackground: .appOrange, pressedBackground: .appOrangePressed))
                            }
                        }
                        .padding([.horizontal, .bottom])
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(TimerViewModel())
        .environmentObject(PresetsViewModel())
        .environmentObject(AppNavigationState())
}
