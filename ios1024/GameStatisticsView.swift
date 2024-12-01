import SwiftUI

struct GameStatisticsView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var sortBy: SortBy = .dateTime
    @Environment(\.dismiss) var dismiss

    enum SortBy {
        case stepsAscending, stepsDescending, dateTime
    }

    var body: some View {
        VStack {
            Text("Welcome, \(viewModel.userRealName)")
                .font(.title)
                .padding()

            Text("Total Games Played: \(viewModel.gameStatistics.count)")
            Text("Average Steps: \(viewModel.averageSteps, specifier: "%.1f")") // Format to 1 decimal place

            Picker("Sort by", selection: $sortBy) {
                Text("Date/Time").tag(SortBy.dateTime)
                Text("Steps (Ascending)").tag(SortBy.stepsAscending)
                Text("Steps (Descending)").tag(SortBy.stepsDescending)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                // 1. Get the sorted statistics array
                let sortedStats = viewModel.sortedStatistics(by: sortBy)

                // 2. Iterate through the sorted array
                ForEach(sortedStats) { stat in
                    VStack(alignment: .leading) {
                        Text("Steps: \(stat.steps)")
                        Text("Board Size: \(stat.boardSize)")
                        Text("Status: \(stat.status)")
                        Text("Max Score: \(stat.maxScore)")
                        Text("Date/Time: \(stat.dateTime, formatter: Self.dateFormatter)")
                    }
                    .background(stat.status == "WIN" ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                }
            }
            Button("Dismiss") {
                dismiss()
            }
        }
        .onAppear {
            viewModel.loadGameStatistics()
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
