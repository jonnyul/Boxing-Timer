export default function PrivacyPolicy() {
  return (
    <main
      className="min-h-screen py-16 px-6"
      style={{ backgroundColor: "#1C2A4A" }}
    >
      <div className="mx-auto max-w-3xl">
        {/* Header */}
        <header className="mb-12 border-b border-white/20 pb-8">
          <p className="mb-2 text-sm font-semibold uppercase tracking-widest text-blue-300">
            Boxing Timer
          </p>
          <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
            Privacy Policy
          </h1>
          <p className="mt-4 text-base text-white/60">
            Effective Date: March 12, 2026
          </p>
        </header>

        {/* Sections */}
        <div className="space-y-10 text-white/85">
          {/* Introduction */}
          <Section title="Introduction">
            <p>
              Welcome to Boxing Timer. This Privacy Policy explains how
              information is handled when you use the Boxing Timer iOS
              application (&ldquo;the App&rdquo;). Boxing Timer is an interval
              timer designed for boxing, martial arts, and fitness training,
              allowing you to create custom round timers, manage workout
              presets, and track session history.
            </p>
            <p className="mt-3">
              Your privacy is important to us. In short: <strong className="text-white">we do not
              collect, store, or transmit any personal data</strong>. Everything
              you enter or configure in the App stays on your device.
            </p>
          </Section>

          {/* Data Collection */}
          <Section title="Data We Collect">
            <p>
              <strong className="text-white">We collect no personal data whatsoever.</strong> The App
              does not ask for your name, email address, phone number, location,
              or any other identifying information. No account or sign-up is
              required to use the App.
            </p>
            <p className="mt-3">
              There are no usage analytics, crash reporters, or diagnostic data
              pipelines in the App that transmit data to us or any third party.
            </p>
          </Section>

          {/* Local Storage */}
          <Section title="Local Storage">
            <p>
              The App stores data exclusively on your device using Apple&rsquo;s
              standard on-device storage mechanisms, including{" "}
              <code className="rounded bg-white/10 px-1.5 py-0.5 text-sm text-blue-200">
                UserDefaults
              </code>{" "}
              and local JSON files. The data stored locally includes:
            </p>
            <ul className="mt-3 space-y-2 pl-5">
              <ListItem>Timer settings and configurations</ListItem>
              <ListItem>Custom workout presets you have created</ListItem>
              <ListItem>
                Workout history and session records
              </ListItem>
            </ul>
            <p className="mt-3">
              This data never leaves your device and is never shared with us or
              anyone else. You can delete it at any time by uninstalling the App
              or clearing its data in your device&rsquo;s Settings.
            </p>
          </Section>

          {/* No Network Requests */}
          <Section title="No Network Requests">
            <p>
              Boxing Timer makes <strong className="text-white">no network requests</strong> of any
              kind. The App functions entirely offline and does not connect to
              the internet, any external servers, or any remote APIs. There is
              no backend, no cloud sync, and no remote configuration.
            </p>
          </Section>

          {/* No Third-Party Services */}
          <Section title="No Third-Party Services">
            <p>
              The App does not integrate any third-party SDKs or services,
              including but not limited to:
            </p>
            <ul className="mt-3 space-y-2 pl-5">
              <ListItem>Advertising networks or ad SDKs</ListItem>
              <ListItem>
                Analytics platforms (e.g., Firebase, Mixpanel, Amplitude)
              </ListItem>
              <ListItem>Crash reporting tools (e.g., Crashlytics, Sentry)</ListItem>
              <ListItem>Social media SDKs</ListItem>
              <ListItem>Attribution or tracking services</ListItem>
            </ul>
            <p className="mt-3">
              There are no advertisements in the App and we do not monetize your
              data in any way.
            </p>
          </Section>

          {/* Children's Privacy */}
          <Section title="Children&rsquo;s Privacy">
            <p>
              Boxing Timer is suitable for users of all ages. Because we do not
              collect any personal data from anyone, the App is fully compliant
              with the Children&rsquo;s Online Privacy Protection Act (COPPA)
              and similar regulations. We do not knowingly collect data from
              children under 13, or from anyone else.
            </p>
          </Section>

          {/* Changes to This Policy */}
          <Section title="Changes to This Policy">
            <p>
              We may update this Privacy Policy from time to time. Any changes
              will be reflected here with an updated effective date. Because the
              App does not collect contact information, we are unable to notify
              you directly of changes. We encourage you to review this page
              periodically.
            </p>
            <p className="mt-3">
              Continued use of the App after any changes to this policy
              constitutes your acceptance of the revised policy.
            </p>
          </Section>

          {/* Contact */}
          <Section title="Contact Us">
            <p>
              If you have any questions or concerns about this Privacy Policy,
              please contact us at:
            </p>
            <p className="mt-3">
              <a
                href="mailto:privacy@boxingtimer.app"
                className="font-medium text-blue-300 underline underline-offset-2 hover:text-blue-200 transition-colors"
              >
                privacy@boxingtimer.app
              </a>
            </p>
          </Section>
        </div>

        {/* Footer */}
        <footer className="mt-16 border-t border-white/20 pt-8 text-center text-sm text-white/40">
          <p>&copy; {new Date().getFullYear()} Boxing Timer. All rights reserved.</p>
        </footer>
      </div>
    </main>
  );
}

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <h2
        className="mb-4 text-xl font-semibold text-white sm:text-2xl"
        dangerouslySetInnerHTML={{ __html: title }}
      />
      <div className="text-base leading-relaxed text-white/75">{children}</div>
    </section>
  );
}

function ListItem({ children }: { children: React.ReactNode }) {
  return (
    <li className="flex items-start gap-2">
      <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-blue-400" />
      <span>{children}</span>
    </li>
  );
}
