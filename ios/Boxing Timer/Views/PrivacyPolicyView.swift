// PrivacyPolicyView.swift
// Displays the Boxing Timer privacy policy inline. Content mirrors web/site/app/page.tsx.

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIMER")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.appCyan)

                        Text("Privacy\nPolicy")
                            .aggressiveHeading(size: 36)
                            .foregroundColor(.white)

                        Text("Effective Date: March 12, 2026")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                            .padding(.top, 4)
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // Sections
                    PolicySection(title: "Introduction") {
                        PolicyText("Welcome to Boxing Timer. This Privacy Policy explains how information is handled when you use the Boxing Timer iOS application (\"the App\"). Boxing Timer is an interval timer designed for boxing, martial arts, and fitness training, allowing you to create custom round timers, manage workout presets, and track session history.")
                        PolicyText("Your privacy is important to us. In short: **we do not collect, store, or transmit any personal data**. Everything you enter or configure in the App stays on your device.")
                    }

                    PolicySection(title: "Data We Collect") {
                        PolicyText("**We collect no personal data whatsoever.** The App does not ask for your name, email address, phone number, location, or any other identifying information. No account or sign-up is required to use the App.")
                        PolicyText("There are no usage analytics, crash reporters, or diagnostic data pipelines in the App that transmit data to us or any third party.")
                    }

                    PolicySection(title: "Local Storage") {
                        PolicyText("The App stores data exclusively on your device using Apple's standard on-device storage mechanisms, including UserDefaults and local JSON files. The data stored locally includes:")
                        PolicyBullet("Timer settings and configurations")
                        PolicyBullet("Custom workout presets you have created")
                        PolicyBullet("Workout history and session records")
                        PolicyText("This data never leaves your device and is never shared with us or anyone else. You can delete it at any time by uninstalling the App or clearing its data in your device's Settings.")
                    }

                    PolicySection(title: "No Network Requests") {
                        PolicyText("Boxing Timer makes **no network requests** of any kind. The App functions entirely offline and does not connect to the internet, any external servers, or any remote APIs. There is no backend, no cloud sync, and no remote configuration.")
                    }

                    PolicySection(title: "No Third-Party Services") {
                        PolicyText("The App does not integrate any third-party SDKs or services, including but not limited to:")
                        PolicyBullet("Advertising networks or ad SDKs")
                        PolicyBullet("Analytics platforms (e.g., Firebase, Mixpanel, Amplitude)")
                        PolicyBullet("Crash reporting tools (e.g., Crashlytics, Sentry)")
                        PolicyBullet("Social media SDKs")
                        PolicyBullet("Attribution or tracking services")
                        PolicyText("There are no advertisements in the App and we do not monetize your data in any way.")
                    }

                    PolicySection(title: "Children's Privacy") {
                        PolicyText("Boxing Timer is suitable for users of all ages. Because we do not collect any personal data from anyone, the App is fully compliant with the Children's Online Privacy Protection Act (COPPA) and similar regulations. We do not knowingly collect data from children under 13, or from anyone else.")
                    }

                    PolicySection(title: "Changes to This Policy") {
                        PolicyText("We may update this Privacy Policy from time to time. Any changes will be reflected here with an updated effective date. Because the App does not collect contact information, we are unable to notify you directly of changes. We encourage you to review this page periodically.")
                        PolicyText("Continued use of the App after any changes to this policy constitutes your acceptance of the revised policy.")
                    }

                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
    }
}

// MARK: - Helpers

private struct PolicySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            content()
        }
    }
}

// Renders plain text; wraps **bold** markers using AttributedString.
private struct PolicyText: View {
    let raw: String

    init(_ raw: String) {
        self.raw = raw
    }

    var body: some View {
        Text(attributed)
            .font(.system(size: 15))
            .foregroundColor(.white.opacity(0.75))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributed: AttributedString {
        var result = AttributedString()
        let parts = raw.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            var segment = AttributedString(part)
            if i % 2 == 1 {
                // Odd segments are between ** markers → bold + white
                segment.font = .system(size: 15, weight: .semibold)
                segment.foregroundColor = .white
            }
            result.append(segment)
        }
        return result
    }
}

private struct PolicyBullet: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
