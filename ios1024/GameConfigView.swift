//
//  GameConfigView.swift
//  ios1024
//
//  Created by Wesley Harrison on 11/30/24.
//

import SwiftUI

struct GameConfigView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Game Configuration")
                .font(.title)
                .padding()

            Stepper("Grid Size: \(viewModel.gridSize)", value: $viewModel.gridSize, in: 3...7)
                .padding()

            Picker("Goal Number", selection: $viewModel.goalNumber) {
                ForEach([64, 128, 256, 512, 1024, 2048], id: \.self) { number in
                    Text("\(number)")
                }
            }
            .padding()

            Button("Back to Game") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

