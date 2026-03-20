import SwiftUI
import AVFoundation
import UIKit

@main
struct Boxing_TimerApp: App {
    @StateObject private var timerVM = TimerViewModel()
    @StateObject private var presetsVM = PresetsViewModel()
    @StateObject private var statsVM = StatsViewModel()
    @StateObject private var navigationState = AppNavigationState()

    init() {
        configureAudioSession()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $navigationState.selectedTab) {
                HomeView()
                    .tag(AppTab.timer)
                    .tabItem {
                        AppTabLabel(
                            title: "Timer",
                            symbol: "clock.fill",
                            color: UIColor(Color.appCyan)
                        )
                    }
                PresetsView()
                    .tag(AppTab.presets)
                    .tabItem {
                        AppTabLabel(
                            title: "Presets",
                            symbol: "slider.horizontal.3",
                            color: .systemOrange
                        )
                    }
                StatsView()
                    .tag(AppTab.stats)
                    .tabItem {
                        AppTabLabel(
                            title: "Stats",
                            symbol: "chart.bar.fill",
                            color: .systemGreen
                        )
                    }
                OptionsView()
                    .tag(AppTab.settings)
                    .tabItem {
                        AppTabLabel(
                            title: "Settings",
                            symbol: "gearshape.fill",
                            color: .systemGray
                        )
                    }
            }
            .environmentObject(timerVM)
            .environmentObject(presetsVM)
            .environmentObject(statsVM)
            .environmentObject(navigationState)
            .tint(.white)
            .preferredColorScheme(.dark)
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    private func configureAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color.appBackgroundDeep)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.appBackgroundDeep)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

private struct AppTabLabel: View {
    let title: String
    let symbol: String
    let color: UIColor

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(uiImage: UIImage(systemName: symbol)?
                .withTintColor(color, renderingMode: .alwaysOriginal) ?? UIImage())
        }
    }
}
