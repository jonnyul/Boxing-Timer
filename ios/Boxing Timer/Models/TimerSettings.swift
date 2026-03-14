import Foundation

struct TimerSettings: Codable, Equatable, Sendable {
    var numberOfRounds = 12
    var roundDuration = 180
    var breakDuration = 60
    var roundEndNotice = 10
    var breakEndNotice = 10
    var getReadyDuration = 5
    var bellsType = 1

    var totalSeconds: Int {
        getReadyDuration + (numberOfRounds * roundDuration) + (max(0, numberOfRounds - 1) * breakDuration)
    }

    var totalTimeFormatted: String { totalSeconds.mmss }
}
