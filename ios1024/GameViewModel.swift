//
//  GameViewMode.swift
//  ios1024
//
//  Created by Hans Dulimarta for CIS357
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class GameViewModel: ObservableObject {
    @Published var grid: Array<Array<Int>>
    @Published var validSwipes: Int = 0
    @Published var gameStatus: String = "In Progress"
    @Published var gridSize: Int = 4
    @Published var goalNumber: Int = 1024
    @Published var userRealName: String = ""
    @Published var gameStatistics: [GameStatistic] = []
    
    struct GameStatistic: Identifiable {
        let id = UUID()
        let steps: Int
        let boardSize: Int
        let status: String // "WIN" or "LOSE"
        let maxScore: Int
        let dateTime: Date
    }
    
    init () {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    }
    
    var averageSteps: Double { // Add this computed property
           guard !gameStatistics.isEmpty else { return 0 }
           let totalSteps = gameStatistics.reduce(0) { $0 + $1.steps }
           return Double(totalSteps) / Double(gameStatistics.count)
       }
    
    
    func addRandomTile() {
        var emptyCells: [(Int, Int)] = []
        for r in 0..<grid.count {
            for c in 0..<grid[r].count {
                if grid[r][c] == 0 { emptyCells.append((r, c))
                }
            }
        }
        if let randomCell = emptyCells.randomElement() {
            grid[randomCell.0][randomCell.1] = Bool.random() ? 2 : 4
        }
    }
    
    func handleSwipe(_ direction: SwipeDirection) {
        var gridChanged = false
        var merged = false
        
        switch direction {
        case .left:
            for r in 0..<grid.count {
                var newRow = [Int]()
                var mergedRow = [Bool](repeating: false, count: 4)
                for c in 0..<grid[r].count {
                    if grid[r][c] != 0 {
                        if !newRow.isEmpty, let last = newRow.last, last == grid[r][c], !mergedRow[newRow.count - 1] {
                            newRow[newRow.count - 1] *= 2
                            mergedRow[newRow.count - 1] = true
                            merged = true
                        } else {
                            newRow.append(grid[r][c])
                        }
                    }
                }
                if newRow.count != grid[r].count {
                    gridChanged = true
                }
                newRow.append(contentsOf: Array(repeating: 0, count: 4 - newRow.count))
                grid[r] = newRow
            }
            
           
            
            
        case .right:
            for r in 0..<grid.count {
                var newRow = [Int]()
                var mergedRow = [Bool](repeating: false, count: 4)
                for c in (0..<grid[r].count).reversed() {
                    if grid[r][c] != 0 {
                        if !newRow.isEmpty, let last = newRow.last, last == grid[r][c], !mergedRow[newRow.count - 1] {
                            newRow[newRow.count - 1] *= 2
                            mergedRow[newRow.count - 1] = true
                            merged = true
                        } else {
                            newRow.append(grid[r][c])
                        }
                    }
                }
                if newRow.count != grid[r].count {
                    gridChanged = true
                }
                newRow.append(contentsOf: Array(repeating: 0, count: 4 - newRow.count))
                grid[r] = newRow.reversed()
            }
            
        case .up:
            for c in 0..<grid[0].count {
                var newCol = [Int]()
                var mergedCol = [Bool](repeating: false, count: 4)
                for r in 0..<grid.count {
                    if grid[r][c] != 0 {
                        if !newCol.isEmpty, let last = newCol.last, last == grid[r][c], !mergedCol[newCol.count - 1] {
                            newCol[newCol.count - 1] *= 2
                            mergedCol[newCol.count - 1] = true
                            merged = true
                        } else {
                            newCol.append(grid[r][c])
                        }
                    }
                }
                if newCol.count != grid.count {
                    gridChanged = true
                }
                newCol.append(contentsOf: Array(repeating: 0, count: 4 - newCol.count))
                for r in 0..<grid.count {
                    grid[r][c] = newCol[r]
                }
            }
            
        case .down:
            for c in 0..<grid[0].count {
                var newCol = [Int]()
                var mergedCol = [Bool](repeating: false, count: 4)
                for r in (0..<grid.count).reversed() {
                    if grid[r][c] != 0 {
                        if !newCol.isEmpty, let last = newCol.last, last == grid[r][c], !mergedCol[newCol.count - 1] {
                            newCol[newCol.count - 1] *= 2
                            mergedCol[newCol.count - 1] = true
                            merged = true
                        } else {
                            newCol.append(grid[r][c])
                        }
                    }
                }
                if newCol.count != grid.count {
                    gridChanged = true
                }
                newCol.append(contentsOf: Array(repeating: 0, count: 4 - newCol.count))
                for r in 0..<grid.count {
                    grid[grid.count - 1 - r][c] = newCol[r]
                }
            }
        }
        
        if gridChanged {
            if !merged {
                addRandomTile()
            }
            validSwipes += 1
            checkGameStatus()
        }
    }
    
    func checkGameStatus() {
        for row in grid {
            if row.contains(1024) {
                gameStatus = "WIN"
                return
            }
        }
        
        var emptyTileExists = false
        
        for r in 0..<grid.count {
            for c in 0..<grid[r].count {
                if grid[r][c] == 0 {
                    emptyTileExists = true
                }
                if r < grid.count - 1, grid[r][c] == grid[r + 1][c] {
                    return
                }
                if c < grid[r].count - 1, grid[r][c] == grid[r][c + 1] {
                    return
                }
            }
        }
        if !emptyTileExists {
            gameStatus = "LOSE"
        } else {
            gameStatus = "In Progress"
        }
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        validSwipes = 0
        //gameStatus = "New Game Initiated"
        addRandomTile()
    }
    
    func signUp(email: String, password: String, realName: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }

            guard let user = authResult?.user else {
                completion(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user after sign up"]))
                return
            }

            // Store the user's real name in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData(["realName": realName]) { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
            } else {
                // Fetch the user's real name from Firestore
                guard let user = authResult?.user else {
                    completion(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user after sign in"]))
                    return
                }

                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { document, error in
                    if let error = error  {
                        completion(error)
                    } else if let document = document, document.exists {
                        self.userRealName = document.get("realName") as? String ?? ""
                        completion(nil)
                    } else {
                        completion(NSError(domain: "SignInError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User document does not exist"]))
                    }
                }
            }
        }
    }
    
    
}

