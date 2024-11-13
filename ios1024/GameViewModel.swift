//
//  GameViewMode.swift
//  ios1024
//
//  Created by Hans Dulimarta for CIS357
//
import SwiftUI
class GameViewModel: ObservableObject {
    @Published var grid: Array<Array<Int>>
    @Published var validSwipes: Int = 0
    @Published var gameStatus: String = "In Progress"
    init () {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
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
    /*func handleSwipe(_ direction: SwipeDirection) {
        let fillValue = switch(direction) {
        case .left:  1
        case .right:  2
        case .up:  3
        case .down:  4
        }
        
        for r in 0 ..< grid.count {
            for c in 0 ..< grid[r].count {
                grid[r][c] = fillValue
            }
        }
    }*/
    
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
    
    
}

