import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            LinearGradient(
                colors: [Color.appRed.opacity(0.3), .clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AppBackground()
}
