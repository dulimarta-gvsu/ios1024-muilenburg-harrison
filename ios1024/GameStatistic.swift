import Foundation
import FirebaseFirestore


// GameStatistic model representing each game record
struct GameStatistic: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore document ID
    var steps: Int               // Number of steps taken to win or lose
    var boardSize: Int           // Board size (e.g., 4 for a 4x4 board)
    var finalState: String       // Game result: "won" or "lost"
    var maxScore: Int            // Maximum score during the game
    var date: Date               // Date and time when the game ended

    // Optional additional fields
    var duration: Int?           // Number of seconds to win or lose (optional)
}

