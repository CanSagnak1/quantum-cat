//
//  LevelCompleteView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct LevelCompleteView: View {
    @ObservedObject var viewModel: GameViewModel

    private var currentLevelData: LevelData? {
        LevelLoader.shared.loadLevel(id: viewModel.currentLevel)
    }

    private var earnedStars: Int {
        var stars = 1

        let parTime = currentLevelData?.parTime ?? 25
        let totalOrbs = currentLevelData?.orbs.count ?? 3

        if viewModel.elapsedTime <= parTime { stars += 1 }
        if viewModel.orbsCollected >= totalOrbs { stars += 1 }
        return min(stars, 3)
    }

    private var hasNextLevel: Bool {
        return viewModel.currentLevel < 30
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))
                    .shadow(color: .yellow.opacity(0.5), radius: 20)

                Text("LEVEL COMPLETE!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < earnedStars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(index < earnedStars ? .yellow : .gray.opacity(0.4))
                            .shadow(
                                color: index < earnedStars ? .yellow.opacity(0.6) : .clear,
                                radius: 10)
                    }
                }
                .padding(.vertical, 10)

                VStack(spacing: 8) {
                    HStack {
                        Text("Time:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(timeString)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Orbs Collected:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(viewModel.orbsCollected)")
                            .foregroundColor(.purple)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Score:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(viewModel.score)")
                            .foregroundColor(.cyan)
                            .fontWeight(.bold)
                    }
                }
                .font(.system(size: 16))
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 30)

                VStack(spacing: 12) {
                    if hasNextLevel {
                        Button(action: {
                            viewModel.currentLevel += 1
                            viewModel.startGame()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("NEXT LEVEL")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.green, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                        }
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
        .onAppear {
            let parTime = currentLevelData?.parTime ?? 25
            let totalOrbs = currentLevelData?.orbs.count ?? 4
            GameProgressManager.shared.completeLevel(
                viewModel.currentLevel,
                score: viewModel.score,
                time: viewModel.elapsedTime,
                parTime: parTime,
                wasCollapsed: false,
                orbsCollected: viewModel.orbsCollected,
                totalOrbs: totalOrbs
            )
        }
    }

    private var timeString: String {
        let minutes = Int(viewModel.elapsedTime) / 60
        let seconds = Int(viewModel.elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
