import Foundation

struct WorkoutSession: Identifiable, Codable, Sendable {
    var id = UUID()
    var date: Date
    var durationMinutes: Int
    var roundsCompleted: Int
    var presetName: String
}
