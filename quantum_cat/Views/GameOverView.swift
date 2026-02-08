//
//  GameOverView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("😿")
                    .font(.system(size: 80))

                Text("QUANTUM COLLAPSE!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("The observer found you...")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                VStack(spacing: 8) {
                    HStack {
                        Text("Time Survived:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(timeString)
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("Orbs Collected:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(viewModel.orbsCollected)")
                            .foregroundColor(.purple)
                    }
                }
                .font(.system(size: 14))
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 30)

                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("RETRY")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }

                    Button(action: {
                        viewModel.returnToMenu()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("LEVEL SELECT")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
            }
        }
    }

    private var timeString: String {
        let minutes = Int(viewModel.elapsedTime) / 60
        let seconds = Int(viewModel.elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
