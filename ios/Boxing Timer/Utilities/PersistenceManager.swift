import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let settingsKey = "timerSettings"
    private let legacyDefaultPresetCleanupKey = "legacyDefaultPresetCleanupCompleted"
    private let presetsFileName = "presets.json"
    private let sessionsFileName = "sessions.json"

    private nonisolated var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private init() {
        removeLegacyDefaultPresetsIfNeeded()
    }

    func loadSettings() -> TimerSettings {
        guard
            let data = UserDefaults.standard.data(forKey: settingsKey),
            let settings = try? JSONDecoder().decode(TimerSettings.self, from: data)
        else {
            return TimerSettings()
        }
        return settings
    }

    func saveSettings(_ settings: TimerSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: settingsKey)
    }

    func loadPresets() -> [Preset] {
        let url = documentsDirectory.appendingPathComponent(presetsFileName)
        guard
            let data = try? Data(contentsOf: url),
            let presets = try? JSONDecoder().decode([Preset].self, from: data)
        else {
            return []
        }
        return presets
    }

    func savePresets(_ presets: [Preset]) {
        let url = documentsDirectory.appendingPathComponent(presetsFileName)
        guard let data = try? JSONEncoder().encode(presets) else { return }
        try? data.write(to: url)
    }

    nonisolated func loadSessions() -> [WorkoutSession] {
        let url = documentsDirectory.appendingPathComponent(sessionsFileName)
        guard
            let data = try? Data(contentsOf: url),
            let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: data)
        else {
            return []
        }
        return sessions
    }

    nonisolated func saveSessions(_ sessions: [WorkoutSession]) {
        let url = documentsDirectory.appendingPathComponent(sessionsFileName)
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        try? data.write(to: url)
    }

    func addSession(_ session: WorkoutSession) {
        var sessions = loadSessions()
        sessions.insert(session, at: 0)
        saveSessions(sessions)
    }

    func clearAllSessions() {
        saveSessions([])
    }

    private func removeLegacyDefaultPresetsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: legacyDefaultPresetCleanupKey) else { return }

        let url = documentsDirectory.appendingPathComponent(presetsFileName)
        defer {
            UserDefaults.standard.set(true, forKey: legacyDefaultPresetCleanupKey)
        }

        guard
            FileManager.default.fileExists(atPath: url.path),
            let data = try? Data(contentsOf: url),
            let presets = try? JSONDecoder().decode([Preset].self, from: data)
        else {
            return
        }

        let filteredPresets = presets.filter { preset in
            !legacyDefaultPresets().contains(where: {
                $0.name == preset.name && $0.settings == preset.settings
            })
        }

        guard filteredPresets.count != presets.count else { return }
        savePresets(filteredPresets)
    }

    private func legacyDefaultPresets() -> [Preset] {
        [
            Preset(
                name: "HIIT 10 x 30/30",
                settings: TimerSettings(
                    numberOfRounds: 10,
                    roundDuration: 30,
                    breakDuration: 30,
                    roundEndNotice: 5,
                    breakEndNotice: 5,
                    getReadyDuration: 5,
                    bellsType: 1
                )
            ),
            Preset(
                name: "Long Boxing",
                settings: TimerSettings(
                    numberOfRounds: 12,
                    roundDuration: 180,
                    breakDuration: 60,
                    roundEndNotice: 10,
                    breakEndNotice: 10,
                    getReadyDuration: 5,
                    bellsType: 1
                )
            ),
            Preset(
                name: "Short Boxing",
                settings: TimerSettings(
                    numberOfRounds: 5,
                    roundDuration: 60,
                    breakDuration: 30,
                    roundEndNotice: 10,
                    breakEndNotice: 10,
                    getReadyDuration: 5,
                    bellsType: 1
                )
            )
        ]
    }
}
