import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GameStatisticsView: View {
    @State private var gameStatistics: [GameStatistic] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    var sortBy: SortBy

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading statistics...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                List(gameStatistics) { stat in
                    GameStatisticRow(statistic: stat)
                }
                .navigationTitle("Game Statistics")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Sort by Steps ↑") {
                            sortStatistics(by: .stepsAscending)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sort by Steps ↓") {
                            sortStatistics(by: .stepsDescending)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("Sort by Date") {
                            sortStatistics(by: .dateTime)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            fetchGameStatistics()
        }
    }

    // Fetch game statistics from Firestore
    private func fetchGameStatistics() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("players").document(userId).collection("gameStatistics")
            .getDocuments { (querySnapshot, error) in
                isLoading = false
                if let error = error {
                    errorMessage = "Failed to load statistics: \(error.localizedDescription)"
                } else {
                    gameStatistics = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: GameStatistic.self)
                    } ?? []
                    sortStatistics(by: sortBy)
                }
            }
    }

    // Sorting options for game statistics
    private func sortStatistics(by option: SortBy) {
        switch option {
        case .stepsAscending:
            gameStatistics.sort { $0.steps < $1.steps }
        case .stepsDescending:
            gameStatistics.sort { $0.steps > $1.steps }
        case .dateTime:
            gameStatistics.sort { $0.date > $1.date }
        }
    }
}

// Placeholder for custom row view for GameStatistic
struct GameStatisticRow: View {
    var statistic: GameStatistic

    var body: some View {
        VStack(alignment: .leading) {
            Text("Steps: \(statistic.steps)")
            Text("Board Size: \(statistic.boardSize)")
            Text("Result: \(statistic.finalState)")
            Text("Max Score: \(statistic.maxScore)")
            Text("Date: \(statistic.date, formatter: dateFormatter)")
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

