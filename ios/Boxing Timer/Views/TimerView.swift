import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerVM: TimerViewModel

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Spacer()

                Text(timerVM.phaseDisplayText)
                    .aggressiveHeading(size: 48)
                    .foregroundColor(phaseBannerColor)
                    .modifier(PulseEffect(active: timerVM.isInNoticeWindow, scale: 1.05))
                    .padding(.bottom, 8)
                Text(timerVM.timeRemaining.mmss)
                    .timerDisplay(size: 96)
                    .padding(.trailing, 4)
                    .foregroundColor(timerVM.isInNoticeWindow ? .appRed : .white)
                    .modifier(PulseEffect(active: timerVM.isInNoticeWindow, scale: 1.03))
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                HStack(spacing: 24) {
                    VStack(spacing: 2) {
                        Text("ELAPSED")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(2)
                            .foregroundColor(.appTextSecondary)
                        Text(timerVM.elapsedTotal.mmss)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.appTextSecondary)
                    }
                    VStack(spacing: 2) {
                        Text("REMAINING")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(2)
                            .foregroundColor(.appTextSecondary)
                        Text(totalRemaining.mmss)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.bottom, 20)
                HStack(spacing: 12) {
                    timerInfoCard(title: "ROUNDS", value: "\(timerVM.currentRound)/\(timerVM.settings.numberOfRounds)", icon: "repeat")
                    timerInfoCard(title: "WORK", value: timerVM.settings.roundDuration.mmss, icon: "flame.fill")
                    timerInfoCard(title: "REST", value: timerVM.settings.breakDuration.mmss, icon: "pause.fill")
                }
                .padding(.horizontal, 20)

                Spacer()

                SegmentedRoundProgressBar(
                    totalRounds: timerVM.settings.numberOfRounds,
                    currentRound: timerVM.currentRound,
                    currentRoundProgress: timerVM.currentRoundProgress,
                    isInNotice: timerVM.isInNoticeWindow,
                    phase: timerVM.phase
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                HStack(spacing: 16) {
                    if timerVM.isPaused {
                        Button("RESUME") {
                            timerVM.resume()
                        }
                        .buttonStyle(.chunkyPrimary)
                    } else {
                        Button("PAUSE") {
                            timerVM.pause()
                        }
                        .buttonStyle(.chunkyGhost)
                    }

                    Button("STOP") {
                        timerVM.stop()
                    }
                    .buttonStyle(.chunkyDanger)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var totalRemaining: Int {
        let settings = timerVM.settings
        let total = settings.totalSeconds
        return max(0, total - timerVM.elapsedTotal)
    }

    private var phaseBannerColor: Color {
        switch timerVM.phase {
        case .getReady: .appCyan
        case .round: .appRed
        case .breakTime: .appCyan
        case .done: .appGreen
        case .idle: .white
        }
    }

    private func timerInfoCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            IconBadge(systemName: icon, color: iconColor(for: icon))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .labelUppercase(size: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func iconColor(for icon: String) -> Color {
        switch icon {
        case "repeat": .green
        case "flame.fill": .orange
        case "pause.fill": .blue
        default: .appCyan
        }
    }
}

struct SegmentedRoundProgressBar: View {
    let totalRounds: Int
    let currentRound: Int
    let currentRoundProgress: Double
    let isInNotice: Bool
    let phase: TimerPhase

    private let barsPerRow = 10
    private let barSpacing: CGFloat = 4
    private let barHeight: CGFloat = 8
    private let rowSpacing: CGFloat = 4

    private var rows: [[Int]] {
        guard totalRounds > 0 else { return [] }
        let rounds = Array(1...totalRounds)
        return stride(from: 0, to: rounds.count, by: barsPerRow).map {
            Array(rounds[$0..<min($0 + barsPerRow, rounds.count)])
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let totalSpacing = barSpacing * CGFloat(barsPerRow - 1)
            let barWidth = (geometry.size.width - totalSpacing) / CGFloat(barsPerRow)

            VStack(spacing: rowSpacing) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    let rowWidth = CGFloat(row.count) * barWidth + CGFloat(row.count - 1) * barSpacing

                    HStack(spacing: barSpacing) {
                        ForEach(row, id: \.self) { round in
                            roundBar(for: round, barWidth: barWidth)
                        }
                    }
                    .frame(width: rowWidth)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: CGFloat(rows.count) * barHeight + CGFloat(max(0, rows.count - 1)) * rowSpacing)
    }

    @ViewBuilder
    private func roundBar(for round: Int, barWidth: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))

            if isCompleted(round: round) {
                Color.appOrange
            } else if isActive(round: round) {
                let progress = min(max(currentRoundProgress, 0), 1)
                Color.appOrange
                    .frame(width: barWidth * CGFloat(progress))
            }
        }
        .frame(width: barWidth, height: barHeight)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func isCompleted(round: Int) -> Bool {
        if round < currentRound { return true }
        if round == currentRound && phase == .breakTime { return true }
        if round == currentRound && phase == .done { return true }
        return false
    }

    private func isActive(round: Int) -> Bool {
        round == currentRound && phase == .round
    }
}

struct PulseEffect: ViewModifier {
    let active: Bool
    var scale: CGFloat = 1.05

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(animating ? scale : 1)
            .onChange(of: active) {
                if active {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        animating = true
                    }
                } else {
                    withAnimation(.spring(duration: 0.15)) {
                        animating = false
                    }
                }
            }
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerViewModel())
}
