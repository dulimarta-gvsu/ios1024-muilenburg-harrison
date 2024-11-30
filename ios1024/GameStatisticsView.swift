import SwiftUI
struct GameStatisticsView: View {
    
    @ObservedObject var viewModel: GameViewModel
    @State private var sortBy: SortBy = .dateTime // Add a state for sorting

    enum SortBy {
        case stepsAscending, stepsDescending, dateTime
    }

    var body: some View {
        VStack {
            // Display the user's real name (fetch this from your viewModel)
            Text("Welcome, \($viewModel.userRealName)") // Assuming you store real name in viewModel
                .font(.title)
                .padding()

            // Display total games, average steps, etc.
            Text("Total Games Played: \(viewModel.gameStatistics.count)")
            Text("Average Steps: \(viewModel.averageSteps)")

            // Add a segmented control or buttons for sorting options
            Picker("Sort by", selection: $sortBy) {
                Text("Date/Time").tag(SortBy.dateTime)
                Text("Steps (Ascending)").tag(SortBy.stepsAscending)
                Text("Steps (Descending)").tag(SortBy.stepsDescending)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                // Assuming you have a 'gameStatistics' array in your viewModel
                ForEach(viewModel.sortedStatistics(by: sortBy)) { stat in
                    VStack(alignment: .leading) {
                        Text("Steps: \(stat.steps)")
                        Text("Board Size: \(stat.boardSize)")
                        Text("Status: \(stat.status)")
                        Text("Max Score: \(stat.maxScore)")
                        // Add more details (date/time, etc.) as needed
                    }
                    .background(stat.status == "WIN" ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                }
            }
        }
        .onAppear {
            viewModel.loadGameStatistics() // Load stats when the view appears
        }
    }
}
