//
//  ContentView.swift
//  ios1024
//
//  Created by Hans Dulimarta for CIS357
//

import SwiftUI

struct GameView: View {
    @State var swipeDirection: SwipeDirection? = .none
    @StateObject var viewModel: GameViewModel = GameViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to 1024 by Jerod and Wes!").font(.title2)

                NumberGrid(viewModel: viewModel)
                    .gesture(DragGesture().onEnded {
                        swipeDirection = determineSwipeDirection($0)
                        viewModel.handleSwipe(swipeDirection!)
                        checkGameStatus()
                    })
                    .onAppear {
                        viewModel.addRandomTile()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)

                /*if let swipeDirection {
                    Text("You swiped \(swipeDirection)")
                }*/
                Text("Valid Swipes: \(viewModel.validSwipes)")
               // Text("Game Status: \(viewModel.gameStatus)")
                    .bold()

                HStack {
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        Text("RESET")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: GameConfigView(viewModel: viewModel)) {
                        Text("SETTINGS")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertMessage),
                    message: Text("Would you like to play again?"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.resetGame()
                    }
                )
            }
        }
    }

    func checkGameStatus() {
        if viewModel.gameStatus == "WIN" {
            alertMessage = "You Win!"
            showingAlert = true
        } else if viewModel.gameStatus == "LOSE" {
            alertMessage = "You Lose!"
            showingAlert = true
        }
    }
}



    // ... rest of your code (NumberGrid, getTileColor, determineSwipeDirection) ...

struct NumberGrid: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<viewModel.gridSize, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<viewModel.gridSize, id: \.self) { column in
                        let cellValue = viewModel.grid[row][column]
                        Text("\(cellValue)")
                            .font(.system(size: 26))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                            .background(getTileColor(value: cellValue))
                            .cornerRadius(10)
                            .foregroundColor(cellValue == 0 ? Color.clear : Color.black)
                    }
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.4))
    }
}

func getTileColor(value: Int) -> Color {
    switch value {
    case 2: return Color.yellow
    case 4: return Color.orange
    case 8: return Color.red
    case 16: return Color.purple
    case 32: return Color.blue
    case 64: return Color.green
    case 128: return Color.pink
    case 256: return Color.cyan
    case 512: return Color.indigo
    case 1024: return Color.teal
    default: return Color.white
    }
}

func determineSwipeDirection(_ swipe: DragGesture.Value) -> SwipeDirection {
    if abs(swipe.translation.width) > abs(swipe.translation.height) {
        return swipe.translation.width < 0 ? .left : .right
    } else {
        return swipe.translation.height < 0 ? .up : .down
    }
}


#Preview {
    GameView()
}
