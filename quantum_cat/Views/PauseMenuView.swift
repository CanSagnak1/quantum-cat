//
//  PauseMenuView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct PauseMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var isPaused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("PAUSED")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 16) {
                    PauseButton(title: "RESUME", icon: "play.fill", color: .green) {
                        isPaused = false
                    }

                    PauseButton(title: "RESTART", icon: "arrow.counterclockwise", color: .orange) {
                        isPaused = false
                        viewModel.resetGame()
                        viewModel.startGame()
                    }

                    PauseButton(title: "MAIN MENU", icon: "house.fill", color: .purple) {
                        isPaused = false
                        viewModel.returnToMenu()
                    }
                }
                .padding(.horizontal, 50)
            }
        }
    }
}

struct PauseButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
        }
    }
}
