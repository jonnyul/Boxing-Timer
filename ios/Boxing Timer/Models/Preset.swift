import Foundation

struct Preset: Identifiable, Codable, Sendable {
    var id = UUID()
    var name: String
    var settings: TimerSettings
}
