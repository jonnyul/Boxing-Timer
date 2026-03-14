import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let appBackground = Color(hex: "1C2A4A")
    static let appBackgroundDeep = Color(hex: "152039")
    static let appCyan = Color(hex: "00F2FF")
    static let appCyanPressed = Color(hex: "5EFAFF")
    static let appRed = Color(hex: "FF003D")
    static let appRedPressed = Color(hex: "FF5C82")
    static let appOrange = Color(hex: "EC5B13")
    static let appOrangePressed = Color(hex: "FF8A4D")
    static let appGreen = Color(hex: "FFD700")
    static let appGreenPressed = Color(hex: "FFE766")
    static let appStatsGreen = Color(hex: "30D158")
    static let appBluePressed = Color(hex: "5DA9FF")
    static let appYellowPressed = Color(hex: "FFD84D")
    static let appTextSecondary = Color(hex: "94A3B8")
    static let appGhostPressed = Color.white.opacity(0.22)
}
