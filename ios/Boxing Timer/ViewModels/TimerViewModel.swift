import Combine
import Foundation
import SwiftUI
import UIKit

enum TimerPhase: String {
    case idle
    case getReady = "GET READY"
    case round = "ROUND"
    case breakTime = "BREAK"
    case done = "DONE"
}

enum AppTab: Hashable {
    case timer
    case presets
    case stats
    case settings
}

@MainActor
final class AppNavigationState: ObservableObject {
    @Published var selectedTab: AppTab = .timer
}

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var currentRound = 0
    @Published var timeRemaining = 0
    @Published var elapsedTotal = 0
    @Published var isPaused = false
    @Published var isInNoticeWindow = false
    @Published var settings: TimerSettings
    @Published var activePresetName = "Custom"
    @Published var currentRoundProgress: Double = 0

    private var timer: Timer?
    private var backgroundedAt: Date?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?
    private var hasSavedCurrentSession = false

    init() {
        settings = PersistenceManager.shared.loadSettings()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var phaseDisplayText: String {
        switch phase {
        case .idle: ""
        case .getReady: "GET READY"
        case .round: "ROUND \(currentRound)"
        case .breakTime: "BREAK"
        case .done: "DONE"
        }
    }

    func start() {
        phase = .getReady
        currentRound = 0
        currentRoundProgress = 0
        timeRemaining = settings.getReadyDuration
        elapsedTotal = 0
        isPaused = false
        isInNoticeWindow = false
        hasSavedCurrentSession = false

        UIApplication.shared.isIdleTimerDisabled = true
        AudioManager.shared.beginBackgroundPlayback()
        AudioManager.shared.playGetReady()

        setupBackgroundObservers()
        startTimerLoop()
    }

    func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
        AudioManager.shared.endBackgroundPlayback()
    }

    func resume() {
        isPaused = false
        AudioManager.shared.beginBackgroundPlayback()
        startTimerLoop()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        removeBackgroundObservers()

        if currentRound >= 1 && !hasSavedCurrentSession {
            saveSession()
        }

        phase = .idle
        currentRound = 0
        currentRoundProgress = 0
        timeRemaining = 0
        elapsedTotal = 0
        isPaused = false
        isInNoticeWindow = false
        hasSavedCurrentSession = false

        UIApplication.shared.isIdleTimerDisabled = false
        AudioManager.shared.endBackgroundPlayback()
    }

    func updateSettings(_ newSettings: TimerSettings) {
        settings = newSettings
        activePresetName = "Custom"
        PersistenceManager.shared.saveSettings(newSettings)
    }

    func loadPreset(_ preset: Preset) {
        settings = preset.settings
        activePresetName = preset.name
        PersistenceManager.shared.saveSettings(settings)
    }

    private func startRoundProgressAnimation() {
        currentRoundProgress = 0
        withAnimation(.linear(duration: Double(settings.roundDuration))) {
            currentRoundProgress = 1
        }
    }

    private func startTimerLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard !isPaused else { return }

        timeRemaining -= 1
        elapsedTotal += 1
        checkNoticeWindow()

        guard timeRemaining <= 0 else { return }
        isInNoticeWindow = false
        advancePhase()
    }

    private func checkNoticeWindow() {
        let noticeTime: Int = switch phase {
        case .round: settings.roundEndNotice
        case .breakTime: settings.breakEndNotice
        default: 0
        }

        guard noticeTime > 0, timeRemaining == noticeTime else { return }
        isInNoticeWindow = true
        AudioManager.shared.playNoticeWarning()
    }

    private func advancePhase() {
        switch phase {
        case .getReady:
            currentRound = 1
            timeRemaining = settings.roundDuration
            phase = .round
            AudioManager.shared.playRoundStart()
            startRoundProgressAnimation()

        case .round:
            currentRoundProgress = 1
            if currentRound < settings.numberOfRounds {
                timeRemaining = settings.breakDuration
                phase = .breakTime
                AudioManager.shared.playRoundEnd()
            } else {
                phase = .done
                AudioManager.shared.playWorkoutComplete()
                saveSession()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.stop()
                }
            }

        case .breakTime:
            currentRound += 1
            timeRemaining = settings.roundDuration
            phase = .round
            AudioManager.shared.playRoundStart()
            startRoundProgressAnimation()

        case .done:
            stop()

        case .idle:
            break
        }

    }

    private func saveSession() {
        hasSavedCurrentSession = true
        PersistenceManager.shared.addSession(
            WorkoutSession(
                date: Date(),
                durationMinutes: elapsedTotal / 60,
                roundsCompleted: currentRound,
                presetName: activePresetName
            )
        )
    }

    private func setupBackgroundObservers() {
        removeBackgroundObservers()

        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleBackground()
            }
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleForeground()
            }
        }
    }

    private func removeBackgroundObservers() {
        if let backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
            self.backgroundObserver = nil
        }
        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
            self.foregroundObserver = nil
        }
    }

    private func handleBackground() {
        guard !AudioManager.shared.isBackgroundPlaybackActive else {
            backgroundedAt = nil
            return
        }

        backgroundedAt = Date()
        timer?.invalidate()
        timer = nil
    }

    private func handleForeground() {
        guard let backgroundedAt, phase != .idle, phase != .done, !isPaused else {
            if !isPaused && phase != .idle && phase != .done {
                startTimerLoop()
            }
            return
        }

        let elapsedInBackground = Int(Date().timeIntervalSince(backgroundedAt))
        self.backgroundedAt = nil
        fastForward(seconds: elapsedInBackground)

        if phase != .idle && phase != .done && !isPaused {
            startTimerLoop()
        }
    }

    private func fastForward(seconds: Int) {
        var remaining = seconds

        while remaining > 0 && phase != .idle && phase != .done {
            if remaining >= timeRemaining {
                remaining -= timeRemaining
                elapsedTotal += timeRemaining
                timeRemaining = 0
                advancePhase()
            } else {
                timeRemaining -= remaining
                elapsedTotal += remaining
                remaining = 0
            }
        }
    }

}
