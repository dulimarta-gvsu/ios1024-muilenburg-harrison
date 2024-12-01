import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @State private var boardSize: Int = 4
    @State private var steps: Int = 0
    @State private var maxScore: Int = 0
    @State private var isGameWon: Bool = false
    @State private var isGameLost: Bool = false
    @State private var showGameStatistics: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("1024 Game")
                .font(.largeTitle)
                .padding()

            Text("Board Size: \(boardSize) x \(boardSize)")
            Text("Steps: \(steps)")
            Text("Max Score: \(maxScore)")

            // Placeholder for the game board
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 300, height: 300)
                .overlay(Text("Game Board Placeholder"))

            // Game Control Buttons
            HStack(spacing: 20) {
                Button(action: restartGame) {
                    Text("Restart Game")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: leaveGame) {
                    Text("Leave Game and Logout")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            Button(action: {
                showGameStatistics = true
            }) {
                Text("Show Game Statistics")
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showGameStatistics) {
                GameStatisticsView(sortBy: .dateTime)  // Pass the default sorting option
            }
        }
        .padding()
        .navigationTitle("Game")
        .onAppear {
            loadSavedGame()
        }
    }

    // Function to restart the game
    private func restartGame() {
        steps = 0
        maxScore = 0
        isGameWon = false
        isGameLost = false
        // Logic to reset the game board goes here
    }

    // Function to leave the game
    private func leaveGame() {
        saveGameState()
        appState.isLoggedIn = false
    }

    // Function to load the saved game from Firestore
    private func loadSavedGame() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("players").document(userId).collection("gameState").document("currentGame")
            .getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        self.boardSize = data["boardSize"] as? Int ?? 4
                        self.steps = data["steps"] as? Int ?? 0
                        self.maxScore = data["maxScore"] as? Int ?? 0
                    }
                }
            }
    }

    // Function to save the game state to Firestore
    private func saveGameState() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let gameData: [String: Any] = [
            "boardSize": boardSize,
            "steps": steps,
            "maxScore": maxScore
        ]
        db.collection("players").document(userId).collection("gameState").document("currentGame").setData(gameData) { error in
            if let error = error {
                print("Failed to save game state: \(error.localizedDescription)")
            }
        }
    }
}


