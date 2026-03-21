import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var timerVM: TimerViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: AppDesign.Layout.rowSpacing) {
                        Text("SETTINGS").foregroundColor(.appTextSecondary)
                            .aggressiveHeading(size: AppDesign.Typography.pageTitleSize)
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                            .padding(.bottom, AppDesign.Layout.titleBottomTrim)
                            .frame(maxWidth: .infinity, alignment: .center)

                        NavigationLink(destination: PrivacyPolicyView()) {
                                HStack(spacing: 12) {
                                    IconBadge(
                                        systemName: "hand.raised.fill",
                                        color: .blue,
                                        size: AppDesign.Control.iconSize + (AppDesign.Control.padding * 2),
                                        iconSize: AppDesign.Control.iconSize
                                    )

                                    Text("Privacy Policy")
                                        .rowTitle()
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(AppDesign.Radius.ten)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Radius.ten)
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
