struct GameStatistic: Identifiable {
    let id = UUID()
    let steps: Int
    let boardSize: Int
    let status: String // "WIN" or "LOSE"
    let maxScore: Int
    let dateTime: Date
}
