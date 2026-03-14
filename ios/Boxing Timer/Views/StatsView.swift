import SwiftUI

struct StatsView: View {
    @EnvironmentObject var statsVM: StatsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            Spacer()
                            VStack(alignment: .center, spacing: 4) {
                                Text("TRAINING")
                                    .aggressiveHeading(size: 32)
                                    .foregroundColor(.white)
                                Text("STATS")
                                    .aggressiveHeading(size: 32)
                                    .foregroundColor(.appStatsGreen)
                            }
                            Spacer()
                        }
                        .padding(.top, 20)

                        HStack(spacing: 12) {
                            StatSummaryCard(title: "SESSIONS", value: "\(statsVM.totalWorkouts)", icon: "figure.boxing", iconColor: .orange)
                            StatSummaryCard(title: "MINUTES", value: "\(statsVM.totalMinutes)", icon: "clock.fill", iconColor: .blue)
                            StatSummaryCard(title: "ROUNDS", value: "\(statsVM.totalRounds)", icon: "repeat", iconColor: .green)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("PAST 365 DAYS")
                                .labelUppercase()

                            ContributionHeatmap(sessions: statsVM.sessions)
                        }
                        .cardStyle()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                statsVM.loadSessions()
            }
        }
    }
}

struct StatSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = .appCyan

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)

            Text(value)
                .font(.system(size: 28, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            Text(title)
                .labelUppercase(size: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct ContributionHeatmap: View {
    let sessions: [WorkoutSession]

    private let dayCount = 365
    private let columnCount = 18
    private let spacing: CGFloat = 4

    @State private var squareSize: CGFloat = 14

    var body: some View {
        let counts = dailyCounts
        let maxCount = max(counts.values.max() ?? 1, 1)

        VStack(alignment: .leading, spacing: 12) {
            Canvas { context, size in
                let size = max(8, floor((size.width - CGFloat(columnCount - 1) * spacing) / CGFloat(columnCount)))
                for (index, day) in days.enumerated() {
                    let count = counts[day] ?? 0
                    let column = index % columnCount
                    let row = index / columnCount
                    let x = CGFloat(column) * (size + spacing)
                    let y = CGFloat(row) * (size + spacing)

                    let fillColor: Color
                    if count > 0 {
                        let intensity = Double(count) / Double(maxCount)
                        fillColor = Color.appStatsGreen.opacity(0.25 + intensity * 0.75)
                    } else {
                        fillColor = Color.white.opacity(0.06)
                    }

                    context.fill(
                        Path(roundedRect: CGRect(x: x, y: y, width: size, height: size), cornerRadius: 3),
                        with: .color(fillColor)
                    )
                }
            }
            .frame(height: CGFloat(rowCount) * squareSize + CGFloat(rowCount - 1) * spacing)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                squareSize = max(8, floor((width - CGFloat(columnCount - 1) * spacing) / CGFloat(columnCount)))
            }

            HStack(spacing: 4) {
                Spacer()
                Text("Less")
                    .font(.system(size: max(9, squareSize * 0.8), weight: .medium))
                    .foregroundColor(.appTextSecondary)

                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(level == 0 ? Color.white.opacity(0.06) : Color.appStatsGreen.opacity(0.25 + level * 0.75))
                        .frame(width: squareSize, height: squareSize)
                }

                Text("More")
                    .font(.system(size: max(9, squareSize * 0.8), weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(.top, 4)
        }
    }

    private var dailyCounts: [Date: Int] {
        let calendar = Calendar.current
        return sessions.reduce(into: [:]) { counts, session in
            counts[calendar.startOfDay(for: session.date), default: 0] += 1
        }
    }

    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<dayCount).compactMap {
            calendar.date(byAdding: .day, value: -((dayCount - 1) - $0), to: today)
        }
    }

    private var rowCount: Int {
        Int(ceil(Double(dayCount) / Double(columnCount)))
    }
}

#Preview {
    StatsView()
        .environmentObject(StatsViewModel())
}
