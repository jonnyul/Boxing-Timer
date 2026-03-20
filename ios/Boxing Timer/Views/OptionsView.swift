import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerVM: TimerViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 12) {
                        Text("SETTINGS").foregroundColor(.appTextSecondary)
                            .aggressiveHeading(size: 32)
                            .frame(maxWidth: .infinity, alignment: .center)

                        NavigationLink(destination: PrivacyPolicyView()) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "hand.raised.fill", color: .blue)

                                    Text("Privacy Policy")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OptionsView()
        .environmentObject(TimerViewModel())
}
