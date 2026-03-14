import Foundation

extension Int {
    var mmss: String {
        String(format: "%02d:%02d", self / 60, self % 60)
    }
}
