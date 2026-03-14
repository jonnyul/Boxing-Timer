import Combine
import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var sessions: [WorkoutSession] = []

    init() {
        loadSessions()
    }

    var totalWorkouts: Int { sessions.count }
    var totalMinutes: Int { sessions.reduce(0) { $0 + $1.durationMinutes } }
    var totalRounds: Int { sessions.reduce(0) { $0 + $1.roundsCompleted } }

    func loadSessions() {
        let persistence = PersistenceManager.shared
        Task {
            sessions = await Task.detached(priority: .userInitiated) {
                persistence.loadSessions()
            }.value
        }
    }

    func clearAllSessions() {
        sessions.removeAll()
        PersistenceManager.shared.clearAllSessions()
    }
}
