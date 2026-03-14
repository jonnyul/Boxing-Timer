import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerVM: TimerViewModel
    @Environment(\.openURL) private var openURL
    @State private var settings = TimerSettings()

    private let privacyPolicyURL: URL? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("APP")
                                    .aggressiveHeading(size: 32)
                                    .foregroundColor(.white)
                                Text("SETTINGS")
                                    .aggressiveHeading(size: 32)
                                    .foregroundColor(.appTextSecondary)
                            }

                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "AUDIO CONFIGURATION")

                            VStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 12) {
                                        IconBadge(systemName: "bell.and.waves.left.and.right", color: .orange)

                                        Text("Bell Type")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(.white)

                                        Spacer()
                                    }

                                    SegmentedPicker(
                                        selection: Binding(
                                            get: { settings.bellsType },
                                            set: { newValue in
                                                settings.bellsType = newValue
                                                saveSettings()
                                                AudioManager.shared.playPreview(bellType: newValue)
                                            }
                                        ),
                                        options: [1, 2, 3],
                                        labels: [1: "Classic", 2: "Modern", 3: "Digital"]
                                    )
                                }
                                .padding(16)
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "PRIVACY")

                            Button {
                                guard let privacyPolicyURL else { return }
                                openURL(privacyPolicyURL)
                            } label: {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "hand.raised.fill", color: .blue)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Privacy Policy")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.white)
                                        Text("Add your URL in `OptionsView.swift`.")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.appTextSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PressFeedbackButtonStyle(cornerRadius: 16, normalBackground: Color.white.opacity(0.05), pressedBackground: Color.white.opacity(0.05)))
                        }

                        Spacer()
                        Text("Boxing Timer v1.0")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                settings = PersistenceManager.shared.loadSettings()
            }
        }
    }

    private func saveSettings() {
        PersistenceManager.shared.saveSettings(settings)
        timerVM.updateSettings(settings)
    }
}

#Preview {
    OptionsView()
        .environmentObject(TimerViewModel())
}
